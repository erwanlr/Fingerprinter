require 'uri'
require 'readline'
require 'nokogiri'
require 'ignore_pattern'
require 'ruby-progressbar'

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
    db_version  = Version.create(number: version_number)

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

  # @param [ Boolean ] version
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

  # @param [ String ] url
  # @param [ Hash ] opts
  #   :unique
  #   :verbose
  def fingerprint(url, opts = {})
    url += '/' if url[-1, 1] != '/'

    uri               = URI.parse(url)
    detected_versions = []
    fingerprints      = fingerprints(opts[:unique])
    bar               = ProgressBar.create(total: fingerprints.size, title: 'Fingerprinting -', format: '%t %a <%B> (%c / %C) %P%% %e')

    fingerprints.each do |path, f|
      bar.progress += 1

      url    = uri.merge(URI.encode(path)).to_s
      md5sum = web_page_md5(url)

      next unless f.key?(md5sum)

      versions = f[md5sum]

      if versions.size == 1
        puts
        puts "Unique Match found for v#{versions.first}:"
        puts " - #{url} -> #{md5sum}"
        return
      else
        detected_versions << versions
      end
    end

    if detected_versions.empty?
      puts 'No match found'
    else
      puts "Potential versions: #{detected_versions.inject(:&).join(', ')}"
    end
  end
end
