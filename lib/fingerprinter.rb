require 'db'
require 'json'
require 'typhoeus'
require 'addressable/uri'
require 'active_support/inflector'
require 'experimental'
require 'fingerprinter/archive'
require 'fingerprinter/actions'
require 'fingerprinter/github_hosted'

# Fingerprinter
class Fingerprinter
  include DB

  # @param [ String ] app_name
  # @param [ Hash ] options See #new
  #
  # @return [ Fingerprinter ]
  def self.load(app_name, options = {})
    if SUPPORTED_APPS.include?(app_name.downcase)
      Object.const_get(app_name.downcase.tr('-', '_').camelize).new(options)
    else
      fail "The application #{app_name} is not supported. Currently supported: #{SUPPORTED_APPS.join(', ')}"
    end
  end

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

    @proxy           = options[:proxy]
    @cookies_file    = options[:cookies_file]
    @cookies_string  = options[:cookies_string]
    @timeout         = options[:timeout]
    @connect_timeout = options[:connecttimeout]
  end

  def app_name
    Object.const_get(self.class.to_s).to_s.underscore
  end

  # @return [ Hash ] The versions and their download urls
  def downloadable_versions
    fail NotImplementedError
  end

  protected

  def request_options
    opts = {
      proxy: @proxy,
      ssl_verifypeer: false,
      ssl_verifyhost: 2,
      cookie: @cookies_string,
      timeout: @timeout,
      connecttimeout: @connect_timeout
    }
    # The option cookiefile of Typhoeus does not work, so we use the cookie one
    opts.merge!(cookie: File.read(@cookies_file)) if @cookies_file
    opts
  end
end
