require 'optparse'

@options = {
  verbose:    false,
  db_verbose: false,
  update:     false,
  update_all: false
}

SUPPORTED_APPS = %w(wordpress fckeditor apache-icons phpmyadmin tinymce drupal umbraco cms-made-simple ckeditor)

OptionParser.new('Usage: ./fingerprinter.rb [options]', 50) do |opts|
  opts.on('--proxy PROXY', '-p', 'Proxy to use during the fingerprinting') do |proxy|
    @options[:proxy] = proxy
  end

  opts.on('--cookies-file FILE-PATH', '--cf', 'The cookies file to use during the fingerprinting') do |file_path|
    @options[:cookies_file] = file_path
  end

  opts.on('--app-name APPLICATION', '-a', "The application to fingerprint. Currently supported: #{SUPPORTED_APPS.join(', ')}") do |app|
    @options[:app] = app
  end

  opts.on('--db PATH-TO-DB', '-d', 'Path to the db of the app-name') do |db|
    @options[:db] = db
  end

  opts.on('--update', '-u', 'Update the db of the app-name') do
    @options[:update] = true
  end

  opts.on('--update-all', '--ua', 'Update all the apps') do
    @options[:update_all] = true
  end

  opts.on('--show-unique-fingerprints VERSION', '--suf', 'Output the unique file hashes for the given version of the app-name') do |version|
    @options[:version] = version
  end

  opts.on('--search-hash HASH', '--sh', 'Search the hash and output the app-name versions & file') do |hash|
    @options[:hash] = hash
  end

  opts.on('--search-file RELATIVE-FILE-PATH', '--sf', 'Search the file and output the app-name versions & hashes') do |file|
    @options[:file] = file
  end

  opts.on('--fingerprint URL', 'Fingerprint the app-name at the given URL using all fingerprints') do |url|
    @options[:app_url] = url
  end

  opts.on('--unique-fingerprint URL', '--uf', 'Fingerprint the app-name at the given URL using unique fingerprints') do |url|
    @options[:app_url] = url
    @options[:unique]  = true
  end

  opts.on('--db-verbose', '--dbv', 'Database Verbose Mode') do
    @options[:db_verbose] = true
  end

  opts.on('--verbose', '-v', 'Verbose Mode') do
    @options[:verbose] = true
  end
end.parse!
