
require 'optparse'

@db_verbose = false
@update     = false
@verbose    = false
@unique     = false

OptionParser.new("Usage: ruby #{$PROGRAM_NAME} [options]", 50) do |opts|
  opts.on('--db PATH-TO-DB', '-d', 'Path to the db') do |db|
    @db = db
  end

  opts.on('--db-verbose', '--dbv', 'databse Verbose Mode') do
    @db_verbose = true
  end

  opts.on('--update', '-u', 'Update the db') do
    @update = true
  end

  opts.on('--verbose', '-v', 'Verbose Mode') do
    @verbose = true
  end

  opts.on('--service SERVICE', '-s', 'The service to fingerprint') do |service|
    @service = service.downcase
  end

  opts.on('--show-unique-fingerprints VERSION', '--suf', 'Output the unique file hashes for the given version of the service') do |version|
    @version = version
  end

  opts.on('--search-hash HASH', '--sh', 'Search the hash and output the Service versions & file') do |hash|
    @hash = hash
  end

  opts.on('--search-file RELATIVE-FILE-PATH', '--sf', 'Search the file and output the Service versions & hashes') do |file|
    @file = file
  end

  opts.on('--fingerprint URL', 'Fingerprint the service using all fingerprints') do |url|
    @target_url = url
    # @target_url += '/' if @target_url[-1, 1] != '/'
  end

  opts.on('--unique-fingerprint URL', '--uf' 'Fingerprint the service using unique fingerprints') do |url|
    @target_url = url
    @unique     = true
  end
end.parse!
