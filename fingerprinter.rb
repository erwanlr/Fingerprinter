#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'uri'
require 'dm-core'
require 'dm-migrations'
require 'dm-constraints'
require 'nokogiri'
require 'typhoeus'

require 'helper'
require 'fingerprinter'
require 'fingerprinters/wordpress'
require 'fingerprinters/fckeditor'

begin
  require 'cli_options'

  url = 'http://downloads.sourceforge.net/project/fckeditor/FCKeditor/1.3/FCKeditor_1.3.zip'
  # url = 'http://downloads.sourceforge.net/project/fckeditor/FCKeditor/2.6.10/FCKeditor_2.6.10.zip'
  file = '/tmp/fckeditor-1.3.zip'
  download_archive(url, file)
  extract_archive(file, '/tmp/fckeditor-1.3')
rescue => e
  puts e.message
end
