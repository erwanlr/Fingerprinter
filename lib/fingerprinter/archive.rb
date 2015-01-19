require 'dearchiver'
require 'fileutils'

# Fingerprinter Archive methods
class Fingerprinter
  # @return [ String ] The directory path where the version has been extracted
  def download_and_extract(version_number, download_url)
    archive_dir  = "/tmp/#{app_name}-#{version_number}/"
    archive_path = "/tmp/#{app_name}-#{version_number}#{archive_extension(download_url)}"

    puts "Downloading and extracting v#{version_number} to #{archive_dir} (#{archive_path})"

    download_archive(download_url, archive_path)
    extract_archive(archive_path, archive_dir)
    FileUtils.rm(archive_path)

    archive_dir
  end

  # @param [ String ] archive_url
  # @param [ String ] dest
  def download_archive(archive_url, dest)
    %x{wget -q -np -O #{dest} #{archive_url} > /dev/null}

    fail 'Download error' unless $CHILD_STATUS != 0 && File.exists?(dest)
  end

  # @param [ String ] archive_path The archive file path
  # @param [ String ] dest The directory to extract to
  def extract_archive(archive_path, dest)
    FileUtils.rm_rf(dest, secure: true)
    FileUtils.mkdir_p(dest)

    a = Dearchiver.new(filename: archive_path)
    fail 'CRC Error' unless a.crc_ok?
    a.extract_to(dest)

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
