#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'helper'
require 'fingerprinters'

begin
  require 'cli_options'

  fail 'No app-name supplied' unless @options[:app]

  f = Object.const_get(@options[:app].capitalize).new(@options[:db], @options[:db_verbose])

  f.update if @options[:update]

  f.show_unique_fingerprints(@options[:version]) if @options[:version]

  f.search_hash(@options[:hash]) if @options[:hash]

  f.search_file(@options[:file]) if @options[:file]

  f.fingerprint(@options[:app_url], @options) if @options[:app_url]
rescue => e
  puts e.message
  puts e.backtrace.join("\n")
end
