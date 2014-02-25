require 'db'
require 'typhoeus'
require 'fingerprinter/archive'
require 'fingerprinter/actions'

# Fingerprinter
class Fingerprinter
  include DB

  # @param [ Hash ] options
  #   :db
  #   :db_verbose
  #   :cookies_file
  def initialize(options = {})
    db = options[:db] || File.join(DB_DIR, "#{app_name}.db")
    # If the db is not an absolute path, we need to get the abslute path
    # otherwise, DataMapper will not be able to find the db
    db = File.expand_path(File.join(Dir.pwd, db)) unless absolute_path?(db)

    init_db(db, options[:db_verbose])

    @proxy        = options[:proxy]
    @cookies_file = options[:cookies_file]
  end

  def app_name
    Object.const_get(self.class.to_s).to_s.downcase
  end

  # @return [ Hash ] The versions and their download urls (should be DESC sorted)
  def downloadable_versions
    fail NotImplementedError
  end

  # Pattern to ignore files during the creation of the fingerprints
  # Default: no file ignored
  def ignore_pattern
    nil
  end

  def web_page_md5(url)
    Digest::MD5.hexdigest(Typhoeus.get(url, request_options).body)
  end

  protected

  def request_options
    opts = {
      proxy: @proxy,
      ssl_verifypeer: false,
      ssl_verifyhost: 2
    }
    # The option cookiefile of Typhoeus does not work, so we use the cookie one
    opts.merge!(cookie: File.read(@cookies_file)) if @cookies_file
    opts
  end
end
