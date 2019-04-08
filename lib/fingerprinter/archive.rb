# frozen_string_literal: true

require 'dearchiver'
require 'fileutils'
require 'shellwords'

# PRs related to the below sent & merged, but no new version released:
# https://github.com/eljuanchosf/dearchiver/pull/2
# https://github.com/eljuanchosf/dearchiver/pull/3
# https://github.com/eljuanchosf/dearchiver/pull/4
module Dearchiver
  # @author Juan Pablo Genovese
  #
  class Processor
    def initialize(options = {})
      @filename = options[:filename]
      raise ArgumentError, 'Processor: :filename required!' if @filename.nil? || @filename.empty?
      raise 'Processor: :filename does not exist!' unless File.exist?(@filename)

      if options[:archive_type].nil? || options[:archive_type].empty?
        @archive_type = File.extname(@filename) if valid_file_type?
      end
      @archive_type ||= options[:archive_type]
      raise ArgumentError, 'Processor: :archive_type required. :filename does not contain a recognizable extension!' if @archive_type.nil? || @archive_type.empty?
    end

    def crc_ok?
      result = execute_command(archive_options[@archive_type][:crc_check].gsub('<filename>', filename.shellescape))
      result.include?(archive_options[@archive_type][:crc_ok]) ? true : false
    end

    def extract_to(destination)
      raise ArgumentError, 'Processor: destination is required!' if destination.nil? || destination.empty?
      raise 'destination directory is not valid' unless Dir.exist?(destination)

      @list_of_files = []

      result = execute_command(archive_options[@archive_type][:decompress].gsub('<filename>', filename.shellescape).gsub('<extractdir>', destination.shellescape))
      result.scan(archive_options[@archive_type][:file_list_regex]).each do |slice|
        # The gsub("\b","") is a hack to make the list file for unrar work.
        @list_of_files << slice.first.delete("\b").strip
      end
      @list_of_files
    end

    def execute_command(command)
      @executed_command = command

      @execution_output = `#{command}`.encode('UTF-8', invalid: :replace, undef: :replace)
    end
  end
end

# Fingerprinter Archive methods
class Fingerprinter
  # @return [ String ] The directory path where the version has been extracted
  def download_and_extract(version_number, download_url)
    archive_dir  = "/tmp/#{app_name}-#{version_number}/"
    archive_path = "/tmp/#{app_name}-#{version_number}#{archive_extension(download_url)}"

    puts "Downloading and extracting v#{version_number} (#{download_url}) to #{archive_dir} (#{archive_path})"

    download_archive(download_url, archive_path)
    extract_archive(archive_path, archive_dir)
    FileUtils.rm(archive_path)

    archive_dir
  end

  # @param [ String ] archive_url
  # @param [ String ] dest
  def download_archive(archive_url, dest)
    `wget -q -np -O #{dest.shellescape} #{archive_url.shellescape} > /dev/null`

    check_downloaded_file(dest)
  end

  def check_downloaded_file(dest)
    exit_status = $CHILD_STATUS.exitstatus

    raise "Download error (Exit Status: #{exit_status})" unless exit_status == 0 && File.exist?(dest)
  end

  # @param [ String ] archive_path The archive file path
  # @param [ String ] dest The directory to extract to
  def extract_archive(archive_path, dest)
    FileUtils.rm_rf(dest, secure: true)
    FileUtils.mkdir_p(dest)

    a = Dearchiver.new(filename: archive_path)
    raise 'CRC Error' unless a.crc_ok?

    a.extract_to(dest)

    raise 'No files extracted' if Dir[File.join(dest, '**', '*.*')].empty?

    # If the archive had a directory containing the files
    # we move all the files at the root of dest
    dirs = Dir[File.join(dest, '**')]
    rebase(dirs.first, dest) if dirs.size == 1
  end

  # Move the directory src to dest
  # It's not a simple mv because src and dest have the same root directory (i.e the version directory)
  def rebase(src, dest)
    FileUtils.mv(src, "#{dest.chomp('/')}-new")
    FileUtils.rm_rf(dest, secure: true)
    FileUtils.mv("#{dest.chomp('/')}-new", dest)
  end

  def file_md5(file_path)
    Digest::MD5.file(file_path).hexdigest
  end
end
