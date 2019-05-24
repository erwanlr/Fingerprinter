# frozen_string_literal: true

require 'English' # fot $CHILD_STATUS
require 'json'
require 'typhoeus'
require 'addressable/uri'
require 'active_support/inflector'
require 'experimental'
require 'fingerprinter/db'
require 'fingerprinter/archive'
require 'fingerprinter/actions'
require 'fingerprinter/github_hosted'

# Helps when network issues
Typhoeus.on_complete do |res|
  raise Typhoeus::Errors::TyphoeusError, "#{res.effective_url} - #{res.code} (#{res.return_message})" if res.code == 0
end

# Fingerprinter
class Fingerprinter
  # @param [ String ] app_name
  # @param [ Hash ] options See #new
  #
  # @return [ Fingerprinter ]
  def self.load(app_name, options = {})
    if SUPPORTED_APPS.include?(app_name.downcase)
      Object.const_get(app_name.downcase.tr('-', '_').camelize).new(options)
    else
      raise "The application #{app_name} is not supported. Currently supported: #{SUPPORTED_APPS.join(', ')}"
    end
  end

  # @param [ Hash ] options
  #   :db
  #   :cookies_file
  #   :app_params
  def initialize(options = {})
    @options = options
  end

  def app_name
    Object.const_get(self.class.to_s).to_s.underscore
  end

  # @return [ Hash ] The versions and their download urls
  def downloadable_versions
    raise NotImplementedError
  end

  protected

  def proxy
    @options[:proxy]
  end

  def cookies_file
    @options[:cookies_file]
  end

  def cookies_string
    @options[:cookies_string]
  end

  def timeout
    @options[:timeout]
  end

  def connect_timeout
    @options[:connecttimeout]
  end

  def request_options
    opts = {
      proxy: proxy,
      ssl_verifypeer: false,
      ssl_verifyhost: 0,
      cookie: cookies_string,
      timeout: timeout,
      connecttimeout: connect_timeout
    }
    # The option cookiefile of Typhoeus does not work, so we use the cookie one
    opts[:cookie] = File.read(cookies_file) if cookies_file
    opts
  end
end
