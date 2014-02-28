require 'uri'
require 'readline'
require 'nokogiri'
require 'ignore_pattern'

# Fingerprinter Actions
class Fingerprinter
  include IgnorePattern::None

  UNIQUE_FINGERPRINTS = 'SELECT md5_hash, path_id, version_id, paths.value AS path FROM fingerprints LEFT JOIN paths ON path_id = id WHERE md5_hash NOT IN (SELECT DISTINCT md5_hash FROM fingerprints WHERE version_id != ?) ORDER BY path ASC'

  def update
    remote_versions = Hash[downloadable_versions.to_a.sort { |a, b| compare_version(a.first, b.first) }]

    puts "#{remote_versions.size} remote versions number retrieved"

    remote_versions.each do |version_number, download_url|
      if !Version.first(number: version_number)
        begin
          compute_fingerprints(
            version_number,
            download_and_extract(version_number, download_url)
          )
        rescue => e
          puts "An error occured: #{e.message}, skipping the version"
        end
      else
        puts "Version #{version_number} already in DB, skipping"
      end
    end
  end

  # @param [ String ] version_number
  # @param [ String ] archive_dir
  # @return [ Void ]
  def compute_fingerprints(version_number, archive_dir)
    db_version  = Version.create(number: version_number)

    puts 'Processing Fingerprints'
    Dir[File.join(archive_dir, '**', '*')].reject { |f| f =~ ignore_pattern || Dir.exists?(f) }.each do |filename|
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
      repository(:default).adapter.select(UNIQUE_FINGERPRINTS, version.id).each do |f|
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
    path = Path.first(value: file)

    puts "Results for #{file}:"

    if path
      Fingerprint.all(path_id: path.id).sort { |a, b| compare_version(a.version.number, b.version.number) }.each do |f|
        puts "  #{f.md5_hash} #{f.version.number}"
      end
    else
      puts 'File not found (the argument must be a relative file path. e.g: wp-admin/css/widgets.css)'
    end
  end

  # @param [ Version ] version
  def fingerprints(version, unique = false)
    if unique
      return repository(:default).adapter.select(UNIQUE_FINGERPRINTS, version.id)
    else
      return version.fingerprints
    end
  end

  # @param [ String ] url
  # @param [ Hash ] options
  #   :unique
  #   :verbose
  def fingerprint(url, options = {})
    url += '/' if url[-1, 1] != '/'
    uri = URI.parse(url)

    Version.all.sort { |a, b| compare_version(a.number, b.number) }.each do |version|
      fingerprints = fingerprints(version, options[:unique])
      total_urls   = fingerprints.count
      matches      = 0
      percent      = 0

      fingerprints.each do |f|
        path = f.path.respond_to?(:value) ? f.path.value : f.path
        url  = uri.merge(path).to_s

        if web_page_md5(url) == f.md5_hash
          matches += 1
          puts "#{url} matches v#{version.number}" if options[:verbose]
        end

        percent = ((matches / total_urls.to_f) * 100).round(2)

        print("Version #{version.number} [#{matches}/#{total_urls} #{percent}% matches]\r")
      end

      puts if total_urls > 0 # Avoiding the new line if the version has no fingerprints (can happen with unique fingerprints)

      if options[:unique] && matches > 0
        puts "The version is very likely to be #{version.number}. Do you still want to continue anyway ? [y/N]"
        break unless Readline.readline =~ /\Ay/i
      end
    end
  end
end
