#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler' # Fixes Bundler issue with Ruby 2.6.1, see https://www.reddit.com/r/ruby/comments/an5bfk/requiring_bundlersetup_gets_wrong_version_of/
require 'bundler/setup'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'helper'
require 'fingerprinters'

begin
  require 'cli_options'

  if @options[:update_all]
    (SUPPORTED_APPS - %w[wordpress-plugin wordpress-theme]).each do |app|
      begin
        puts "Updating #{app}:"
        Fingerprinter.load(app, @options).auto_update(display_skipped: false)
      rescue StandardError => e
        puts "An error occured: #{e.message}, skipping the app"
      ensure
        puts
      end
    end
    exit(1)
  end

  raise 'No app-name supplied' unless @options[:app]

  Typhoeus::Config.user_agent = @options[:user_agent]

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

  if @options[:list_files]
    f.list_files(@options[:list_files])
    exit(1)
  end

  f.list_unique_fingerprints(@options[:list_unique_fingerprints]) if @options[:list_unique_fingerprints]

  f.search_hash(@options[:hash]) if @options[:hash]

  f.search_file(@options[:file]) if @options[:file]

  if @options[:target]
    if @options[:passive]
      f.passive_fingerprint(@options[:target], @options)
    else
      f.fingerprint(@options[:target], @options)
    end
  end
rescue StandardError => e
  puts e.message
  puts e.backtrace.join("\n")
end
