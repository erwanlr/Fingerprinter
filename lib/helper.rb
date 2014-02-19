
require 'dearchiver'
require 'fileutils'
require 'typhoeus'

SCRIPT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
DB_DIR     = File.join(SCRIPT_DIR, 'db')

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
  a.extract_to(dest)

  # If the archive had a directory containing the files
  # we move all the files at the root of dest
  dirs = Dir[File.join(dest, '**')]
  if dirs.size == 1
    FileUtils.mv(dirs.first, "#{dest.chomp('/')}-new")
    FileUtils.rm_rf(dest, secure: true)
    FileUtils.mv("#{dest.chomp('/')}-new", dest)
  end
end

def file_md5(file_path)
  Digest::MD5.file(file_path).hexdigest
end

def web_page_md5(url)
  Digest::MD5.hexdigest(Typhoeus.get(url).body)
end
