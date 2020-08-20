# frozen_string_literal: true

require 'uri'
require 'readline'
require 'nokogiri'
require 'ignore_pattern'
require 'ruby-progressbar'
require 'cms_scanner'

# Fingerprinter Actions
class Fingerprinter
  include IgnorePattern::None

  def auto_update(display_skipped: true)
    puts 'Retrieving remote version numbers ...'

    begin
      remote_versions = Hash[downloadable_versions.to_a.sort { |a, b| compare_version(a.first, b.first) }]

      puts "#{remote_versions.size} remote version numbers retrieved"

      remote_versions.each do |version_number, download_url|
        if !db_versions.include?(version_number)
          begin
            compute_fingerprints(version_number, download_and_extract(version_number, download_url))
          rescue StandardError => e
            puts "An error occurred: #{e.message}, skipping the version"
          end
        elsif display_skipped
          puts "Version #{version_number} already in DB, skipping"
        end
      end

      # Resort and save the data
      db_sort_and_save
    rescue StandardError => e
      puts "Error: #{e.message}"
    end
  end

  def manual_update(opts = {})
    raise 'The --version option has to be supplied' unless opts[:manual_version]

    if !db_versions.include?(opts[:manual_version])
      begin
        compute_fingerprints(opts[:manual_version], opts[:manual])

        db_sort_and_save
      rescue StandardError => e
        puts "An error occurred: #{e.message}, skipping the version"
      end
    else
      puts "Version #{opts[:manual_version]} already in DB, skipping"
    end
  end

  def list_versions
    db_versions.each { |number| puts number }
  end

  def list_files(version_number)
    if db_versions.include?(version_number)
      puts "Results for #{version_number}:"

      db.select { |_, fp| fp.select { |_, versions| versions.include?(version_number) } }.each_key do |file_path|
        puts file_path
      end
    else
      puts "The version supplied: '#{version_number}' is not in the database"
    end
  end

  # @param [ String ] version_number
  # @param [ String ] archive_dir
  # @return [ Void ]
  def compute_fingerprints(version_number, archive_dir)
    # Duppe the DB and save it if everything went well
    # so that if an exception is raised here, there is no partial
    # fingerprints in the DB. As a result, the DB has to be reloaded each time
    # (hence the (true))
    dupped_db = db(true).dup

    puts 'Processing Fingerprints'
    # TODO: Maybe use Pathname ?
    Dir[File.join(archive_dir, '**', '*')].reject { |f| f =~ ignore_pattern || Dir.exist?(f) || !File.size?(f) }.each do |filename|
      md5sum      = Digest::MD5.file(filename).hexdigest
      file_path   = filename.gsub(archive_dir, '')

      dupped_db[file_path] ||= {}
      dupped_db[file_path][md5sum] ||= []
      dupped_db[file_path][md5sum] << version_number
    end

    save_db(dupped_db)
    FileUtils.rm_rf(archive_dir, secure: true)
  end

  # @param [ String ] version_number
  def list_unique_fingerprints(version_number)
    if db_versions.include?(version_number)
      puts "Results for #{version_number}:"

      db.each do |file_path, fingerprints|
        fingerprints.select { |_, versions| versions == [version_number] }.each_key do |md5sum|
          puts "#{md5sum} #{file_path}"
        end
      end
    else
      puts "The version supplied: '#{version_number}' is not in the database"
    end
  end

  def search_hash(hash)
    puts "Results for #{hash}:"

    db.each do |file_path, fingerprints|
      fingerprints.each do |md5sum, versions|
        next unless md5sum == hash

        versions.sort { |a, b| compare_version(a, b) }.each { |number| puts "  #{number} #{file_path}" }
      end
    end
  end

  def search_file(file)
    results = nil

    db.each do |path, fingerprints|
      next unless path.include?(file)

      results = {}
      puts "Results for #{path}:"

      fingerprints.each do |md5sum, versions|
        versions.each do |version|
          results[version] = md5sum
        end
      end

      results.keys.sort { |a, b| compare_version(a, b) }.each do |version|
        puts "   #{results[version]} #{version}"
      end
    end

    puts 'Nothing found' unless results
  end

  # @param [ Boolean ] unique
  #
  # @return [ Hash ]
  def fingerprints(unique = false)
    return db unless unique

    results = {}

    db.each do |file_path, fingerprints|
      fingerprints.each do |md5sum, versions|
        next unless versions.size == 1

        results[file_path] ||= {}
        results[file_path][md5sum] = versions
      end
    end

    results
  end

  # @param [ Hash ] opts
  #
  # @return [ ProgressBar::Base ]
  def progress_bar(opts = {})
    ProgressBar.create({ format: '%t %a <%B> (%c / %C) %P%% %e' }.merge(opts))
  end

  def verbose_format
    '%i - %s - %s'
  end

  # @param [ CMSScanner::Target ] target
  # @param [ Hash ] opts
  #   :unique
  #   :verbose
  def fingerprint(target, opts = {})
    detected_versions = []
    fingerprints      = fingerprints(opts[:unique])
    bar               = progress_bar(total: fingerprints.size, title: 'Fingerprinting -')

    fingerprints.each do |path, f|
      url = target.url(path)

      begin
        res = Typhoeus.get(url, request_options)
      rescue Typhoeus::Errors::TyphoeusError => e
        bar.log("Error: #{e.message}")
        bar.increment
        next
      end

      md5sum   = Digest::MD5.hexdigest(res.body)
      verb_msg = nil

      if (versions = f[md5sum])
        detected_versions << versions
        intersection = detected_versions.inject(:&)

        if versions.size == 1
          bar.log("Unique Match! v#{versions.first} - #{url} -> #{md5sum}")
        elsif intersection.size == 1
          bar.log("Intersection of potential versions is only one: v#{intersection.first} - #{url} -> #{md5sum}")
        else
          verb_msg = format(verbose_format, res.code, "Matches: #{versions.join(', ')}", url)
        end
      else
        verb_msg = format(verbose_format, res.code, 'No Match', url)
      end

      bar.log(verb_msg) if opts[:verbose] && verb_msg
      bar.increment
    end
  rescue Interrupt
    bar.stop
    puts 'Canceled'
  ensure
    puts
    puts potential_version(detected_versions)
  end

  # @param [ Array<String> ] versions
  #
  # @return [ String ]
  def potential_version(versions)
    intersected_versions = versions.inject(:&)

    if intersected_versions.nil?
      'No match found'
    elsif intersected_versions.size == 1
      "Very likely to be v#{intersected_versions.first}"
    elsif !intersected_versions.empty?
      intersected_versions.sort! { |a, b| compare_version(a, b) }
      "Potential versions: #{intersected_versions.join(', ')}"
    else
      s = 'Inconsistency detected, versions were found but their intersection is empty. Detected version arrays:'
      versions.uniq.sort_by(&:size).each { |v| s += "\n#{v.join(', ')}" }

      s
    end
  end

  # @param [ CMSScanner::Target ] target
  # @param [ Hash ] opts
  #   :verbose
  def passive_fingerprint(target, opts = {})
    detected_versions = []
    urls              = target.in_scope_urls(Typhoeus.get(target.url, request_options.merge(followlocation: true)))
    bar               = progress_bar(total: urls.size, title: 'Passively Fingerprinting -')

    urls.each do |url|
      uri          = Addressable::URI.parse(url)
      path         = uri.path.sub(target.uri.path, '')
      fingerprints = db[path]

      if fingerprints.nil? || fingerprints.empty?
        bar.log("Path not in the DB for #{url}") if opts[:verbose]
      else
        # the url will contain the query string, not sure if it should be deleted or not
        res      = Typhoeus.get(url, request_options)
        md5sum   = Digest::MD5.hexdigest(res.body)
        verb_msg = nil

        if (versions = fingerprints[md5sum])
          detected_versions << versions
          intersection = detected_versions.inject(:&)

          if versions.size == 1
            bar.log("Unique Match! v#{versions.first} - #{url} -> #{md5sum}")
          elsif intersection.size == 1
            bar.log("Intersection of potential versions is only one: v#{intersection.first} - #{url} -> #{md5sum}")
          else
            verb_msg = format(verbose_format, res.code, "Matches: #{versions.join(', ')}", url)
          end
        else
          verb_msg = format(verbose_format, res.code, 'No Match', url)
        end

        bar.log(verb_msg) if opts[:verbose] && verb_msg
      end

      bar.increment
    end
  rescue Interrupt
    bar.stop
    puts 'Canceled'
  ensure
    puts
    puts potential_version(detected_versions)
  end
end
