#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'helper'
require 'fingerprinters'

begin
  require 'cli_options'

  if @options[:update_all]
    SUPPORTED_APPS.each do|app|
      puts "Updating #{app}:"
      Fingerprinter.load(app, @options).update
    end
    exit(1)
  end

  fail 'No app-name supplied' unless @options[:app]

  f = Fingerprinter.load(@options[:app], @options)

  if f.respond_to?(:experimental?)
    puts
    puts 'This Fingerprinter has not been tested on a real target yet.'
    puts 'Please report any working options or issues'
    puts
  end

  if @options[:update]
    if @options[:manual]
      f.manual_update(@options)
    else
      f.auto_update
    end
  end

  if @options[:list_versions]
    f.list_versions
    exit(1)
  end

  f.show_unique_fingerprints(@options[:version]) if @options[:version]

  f.search_hash(@options[:hash]) if @options[:hash]

  f.search_file(@options[:file]) if @options[:file]

  f.fingerprint(@options[:app_url], @options) if @options[:app_url]
rescue => e
  puts e.message
  puts e.backtrace.join("\n")
end
