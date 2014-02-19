# Gems
require 'dm-core'
require 'dm-migrations'
require 'dm-constraints'
require 'uri'
require 'nokogiri'
# Custom Libs
require 'db'

# Fingerprinter
class Fingerprinter
  include DB

  # @param [ Hash ] options
  #   :db
  #
  def initialize(db = nil, db_verbose = false)
    db ||= File.join(DB_DIR, "#{app_name}.db")

    init_db(db, db_verbose)
  end

  def app_name
    Object.const_get(self.class.to_s).to_s.downcase
  end

  # @return [ Hash ] The versions and their download link
  def downloadable_versions
    fail NotImplementedError
  end

  # TODO: Maybe less LOC ?
  def update
    remote_versions = downloadable_versions
    puts "#{remote_versions.size} remote versions number retrieved"

    remote_versions.each do |version, download_url|
      if !Version.first(number: version)
        db_version   = Version.create(number: version)
        archive_dir  = "/tmp/#{app_name}-#{version}/"
        archive_path = "/tmp/#{app_name}-#{version}.#{archive_extension}"

        puts "Downloading and extracting v#{version} to #{archive_dir}"
        download_archive(download_url, archive_path)
        extract_archive(archive_path, archive_dir)

        puts 'Processing Fingerprints'
        Dir[File.join(archive_dir, '**', '*')].reject { |f| f =~ ignore_pattern || Dir.exists?(f) }.each do |filename|
          hash = Digest::MD5.file(filename).hexdigest
          file_path = filename.gsub(archive_dir, '')
          db_path = Path.first_or_create(value: file_path)
          fingerprint = Fingerprint.create(path_id: db_path.id, md5_hash: hash)

          db_version.fingerprints << fingerprint
        end
        db_version.save
      else
        puts "Version #{version} already in DB, skipping"
      end
    end
  end

  def show_unique_fingerprints(version_number)
    version = Version.first(number: version_number)

    if version
      repository(:default).adapter.select('SELECT md5_hash, path_id, version_id, paths.value AS path FROM fingerprints LEFT JOIN paths ON path_id = id WHERE md5_hash NOT IN (SELECT DISTINCT md5_hash FROM fingerprints WHERE version_id != ?) ORDER BY path ASC', version.id).each do |f|
        puts "#{f.md5_hash} #{f.path}" if f.version_id == version.id
      end
    else
      puts "The version supplied: '#{version_number}' is not in the database"
    end
  end

  def search_hash(hash)
    puts "Results for #{hash}:"

    Fingerprint.order_by_version(:desc).all(md5_hash: hash).each do |f|
      puts "  #{f.version.number} #{f.path.value}"
    end
  end

  def search_file(file)
    path = Path.first(value: file)

    puts "Results for #{file}:"

    if path
      Fingerprint.order_by_version(:desc).all(path_id: path.id).each do |f|
        puts "  #{f.md5_hash} #{f.version.number}"
      end
    else
      puts 'File not found (the argument must be a relative file path. e.g: wp-admin/css/widgets.css)'
    end
  end

  # @param [ Version ] version
  def fingerprints(version, unique = false)
    if unique
      return repository(:default).adapter.select('SELECT md5_hash, path_id, version_id, paths.value AS path FROM fingerprints LEFT JOIN paths ON path_id = id WHERE md5_hash NOT IN (SELECT DISTINCT md5_hash FROM fingerprints WHERE version_id != ?) ORDER BY path ASC', version.id)
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

    Version.all(order: [:number.desc]).each do |version|
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

      puts if total_urls > 0
    end
  end
end
