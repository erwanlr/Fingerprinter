require 'uri'
require 'readline'
require 'nokogiri'
require 'ignore_pattern'
require 'ruby-progressbar'
require 'cms_scanner'

# Fingerprinter Actions
class Fingerprinter
  include IgnorePattern::None

  UNIQUE_FINGERPRINTS = 'SELECT md5_hash, path_id, version_id, ' \
                        'versions.number AS version,' \
                        'paths.value AS path ' \
                        'FROM fingerprints ' \
                        'LEFT JOIN versions ON version_id = versions.id ' \
                        'LEFT JOIN paths on path_id = paths.id ' \
                        'WHERE md5_hash IN ' \
                        '(SELECT md5_hash FROM fingerprints GROUP BY md5_hash HAVING COUNT(*) = 1) ' \
                        'ORDER BY version DESC'

  ALL_FINGERPRINTS = 'SELECT md5_hash, path_id, version_id, ' \
                     'versions.number AS version,' \
                     'paths.value AS path ' \
                     'FROM fingerprints ' \
                     'LEFT JOIN versions ON version_id = versions.id ' \
                     'LEFT JOIN paths on path_id = paths.id ' \
                     'ORDER BY version DESC'

  PATH_FINGERPRINTS = 'SELECT md5_hash, versions.number AS version ' \
                      'FROM fingerprints '\
                      'LEFT JOIN versions ON version_id = versions.id ' \
                      'LEFT JOIN paths on path_id = paths.id ' \
                      'WHERE paths.value = ? ' \
                      'ORDER BY version DESC'

  def auto_update
    puts 'Retrieving remote version numbers ...'

    remote_versions = Hash[downloadable_versions.to_a.sort { |a, b| compare_version(a.first, b.first) }]

    puts "#{remote_versions.size} remote version numbers retrieved"

    remote_versions.each do |version_number, download_url|
      if !Version.first(number: version_number)
        begin
          compute_fingerprints(version_number, download_and_extract(version_number, download_url))
        rescue => e
          puts "An error occured: #{e.message}, skipping the version"
        end
      else
        puts "Version #{version_number} already in DB, skipping"
      end
    end
  end

  def manual_update(opts = {})
    fail 'The --version option has to be supplied' unless opts[:manual_version]

    if !Version.first(number: opts[:manual_version])
      begin
        compute_fingerprints(opts[:manual_version], opts[:manual])
      rescue => e
        puts "An error occured: #{e.message}, skipping the version"
      end
    else
      puts "Version #{opts[:manual_version]} already in DB, skipping"
    end
  end

  def list_versions
    Version.all.sort { |a, b| compare_version(a.number, b.number) }.each do |version|
      puts version.number
    end
  end

  # @param [ String ] version_number
  # @param [ String ] archive_dir
  # @return [ Void ]
  def compute_fingerprints(version_number, archive_dir)
    db_version = Version.create(number: version_number)

    puts 'Processing Fingerprints'
    Dir[File.join(archive_dir, '**', '*')].reject { |f| f =~ ignore_pattern || Dir.exist?(f) }.each do |filename|
      hash        = Digest::MD5.file(filename).hexdigest
      file_path   = filename.gsub(archive_dir, '')
      db_path     = Path.first_or_create(value: file_path)
      fingerprint = Fingerprint.create(path_id: db_path.id, md5_hash: hash)

      db_version.fingerprints << fingerprint
    end
    db_version.save
    FileUtils.rm_rf(archive_dir, secure: true)
  end

  # @param [ String ] version_number
  def show_unique_fingerprints(version_number)
    version = Version.first(number: version_number)

    if version
      puts "Results for #{version.number}:"

      repository(:default).adapter.select(UNIQUE_FINGERPRINTS).each do |f|
        puts "#{f.md5_hash} #{f.path}" if f.version_id == version.id
      end
    else
      puts "The version supplied: '#{version_number}' is not in the database"
    end
  end

  def search_hash(hash)
    puts "Results for #{hash}:"

    Fingerprint.all(md5_hash: hash).sort { |a, b| compare_version(a.version.number, b.version.number) }.each do |f|
      puts "  #{f.version.number} #{f.path.value}"
    end
  end

  def search_file(file)
    paths = Path.all(:value.like => file)

    paths.each do |path|
      puts "Results for #{path.value}:"

      Fingerprint.all(path_id: path.id).sort { |a, b| compare_version(a.version.number, b.version.number) }.each do |f|
        puts "  #{f.md5_hash} #{f.version.number}"
      end
    end

    puts 'No Results' if paths.empty?
  end

  # @param [ Boolean ] unique
  #
  # @return [ Hash ]
  def fingerprints(unique = false)
    query   = unique ? UNIQUE_FINGERPRINTS : ALL_FINGERPRINTS
    results = {}

    repository(:default).adapter.select(query).each do |f|
      results[f.path] ||= {}
      results[f.path][f.md5_hash] ||= []
      results[f.path][f.md5_hash] << f.version
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
      url      = target.url(path)
      res      = Typhoeus.get(url, request_options)
      md5sum   = Digest::MD5.hexdigest(res.body)
      verb_msg = nil
      versions = f[md5sum]

      if versions
        detected_versions << versions

        if versions.size == 1
          bar.log("Unique Match! v#{versions.first} - #{url} -> #{md5sum}")
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

  def potential_version(versions)
    versions = versions.inject(:&)

    if versions.nil?
      'No match found'
    elsif versions.size == 1
      "Very likely to be v#{versions.first}"
    elsif !versions.empty?
      "Potential versions: #{versions.join(', ')}"
    else
      'Inconsistency detected, versions were found but their intersection is empty, use -v for details'
    end
  end

  # @param [ CMSScanner::Target ] target
  # @param [ Hash ] opts
  #   :verbose
  def passive_fingerprint(target, opts = {})
    urls              = target.in_scope_urls(Typhoeus.get(target.url))
    bar               = progress_bar(total: urls.size, title: 'Passively Fingerprinting -')
    detected_versions = []

    urls.each do |url|
      uri          = Addressable::URI.parse(url)
      path         = uri.path.sub(target.uri.path, '')
      fingerprints = path_fingerprints(path)

      if fingerprints.empty?
        bar.log("Path not in the DB for #{url}") if opts[:verbose]
      else
        # the url will contain the query string, not sure if it should be deleted or not
        res      = Typhoeus.get(url, request_options)
        md5sum   = Digest::MD5.hexdigest(res.body)
        verb_msg = nil
        versions = fingerprints[md5sum]

        if versions
          detected_versions << versions

          if versions.size == 1
            bar.log("Unique Match! v#{versions.first} - #{url} -> #{md5sum}")
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

  # @param [ String ] path
  #
  # @return [ Hash ]
  def path_fingerprints(path)
    results = {}

    repository(:default).adapter.select(PATH_FINGERPRINTS, path).each do |f|
      results[f.md5_hash] ||= []
      results[f.md5_hash] << f.version
    end

    results
  end
end
