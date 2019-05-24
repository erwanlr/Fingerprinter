# frozen_string_literal: true

require 'optparse'

@options = {
  verbose: false,
  update: false,
  update_all: false,
  list_versions: false,
  timeout: 20,
  connecttimeout: 5,
  user_agent: 'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:43.0) Gecko/20100101 Firefox/43.0'
}

OptionParser.new('Usage: ./fingerprinter.rb [options]', 50) do |opts|
  opts.on('--proxy PROXY', '-p', 'Proxy to use during the fingerprinting') do |proxy|
    @options[:proxy] = proxy
  end

  opts.on('--timeout SECONDS', 'The number of seconds for the requests to be performed, default 20s') do |timeout|
    @options[:timeout] = timeout.to_i
  end

  opts.on('--connect-timeout SECONDS', 'The number of seconds for the connection to be established before timeout, default 5s') do |timeout|
    @options[:connecttimeout] = timeout.to_i
  end

  opts.on('--cookies-file FILE-PATH', '--cf', 'The cookies file to use in fingerprinting requests') do |file_path|
    @options[:cookies_file] = file_path
  end

  opts.on('--cookies-string COOKIE/S', '--cs', 'The cookies string to use in fingerprinting requests') do |string|
    @options[:cookies_string] = string
  end

  opts.on('--user-agent UA', '--ua', 'User-Agent to use in fingerprinting requests') do |ua|
    @options[:user_agent] = ua
  end

  opts.on('--app-name APPLICATION', '-a', "The application to fingerprint. Currently supported: #{SUPPORTED_APPS.join(', ')}") do |app|
    @options[:app] = app
  end

  opts.on('--app-params PARAMS', 'Additionnal Parameters to give to the app. Used to provide the plugin/theme name along with the wordpress-plugin/wordpress-theme app') do |params|
    @options[:app_params] = params
  end

  opts.on('--db PATH-TO-DB', '-d', 'Path to the db of the app-name (default is db/<app-name>.json)') do |db|
    @options[:db] = db
  end

  opts.on('--update', '-u', 'Update the db of the app-name') do
    @options[:update] = true
  end

  opts.on('--manual DIRECTORY-PATH', 'To be used along with the --update and --version options. Process the (local) DIRECTORY-PATH and compute the file fingerprints') do |path|
    @options[:manual] = path
  end

  opts.on('--version VERSION', 'Used with --manual to set the version of the processed fingerprints') do |version|
    @options[:manual_version] = version
  end

  opts.on('--update-all', 'Update all the apps, except the wordpress plugins and themes') do
    @options[:update_all] = true
  end

  opts.on('--list-versions', '--lv', 'List all the known versions in the DB for the given app') do
    @options[:list_versions] = true
  end

  opts.on('--list-files VERSION', '--lf', 'List all files related to the version for the given app') do |version|
    @options[:list_files] = version
  end

  opts.on('--list-unique-fingerprints VERSION', '--luf', 'List the unique hashes related to the files for the supplied version of the app') do |version|
    @options[:list_unique_fingerprints] = version
  end

  opts.on('--search-hash HASH', '--sh', 'Search the hash and output the app-name versions & file') do |hash|
    @options[:hash] = hash
  end

  opts.on('--search-file FILE', '--sf', 'Search the file (ie --sf read will return aread.txt, readme.html etc) and output the app-name versions & hashes') do |file|
    @options[:file] = file
  end

  opts.on('--fingerprint URL', '-f', 'Fingerprint the app-name at the given URL using all fingerprints') do |url|
    @options[:target] = CMSScanner::Target.new(url)
  end

  opts.on('--unique-fingerprint URL', '--uf', 'Fingerprint the app-name at the given URL using unique fingerprints') do |url|
    @options[:target] = CMSScanner::Target.new(url)
    @options[:unique] = true
  end

  opts.on('--passive-fingerprint URL', '--pf', 'Passively fingerprint the URL') do |url|
    @options[:target]  = CMSScanner::Target.new(url)
    @options[:passive] = true
  end

  opts.on('--verbose', '-v', 'Verbose Mode') do
    @options[:verbose] = true
  end
end.parse!
