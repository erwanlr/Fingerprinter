
require 'dearchiver'
require 'fileutils'

# @param [ String ] archive_url
# @param [ String ] dest
def download_archive(archive_url, dest)
  %x{wget -q -np -O #{dest} #{archive_url} > /dev/null}

  fail 'Download error' unless $CHILD_STATUS != 0 && File.exists?(dest)
end

# @param [ String ] archive_path The archive file path
# @param [ String ] dest The directory to extract to
def extract_archive(archive_path, dest)
  dest.chomp!('/')
  FileUtils.rm_rf(dest, secure: true)
  FileUtils.mkdir_p(dest)

  a = Dearchiver.new(filename: archive_path)
  a.extract_to(dest)

  # If the archive had a directory containing the files
  # we move all the files at the root of dest
  if a.list_of_files.empty?
    dirs = Dir[File.join(dest, '**')]
    if dirs.size == 1
      FileUtils.mv(dirs.first, "#{dest}-new")
      FileUtils.rm_rf(dest, secure: true)
      FileUtils.mv("#{dest}-new", dest)
    else
      fail "Multiple directories were found in #{dest}, only one was expected"
    end
  end
end
