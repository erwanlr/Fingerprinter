# frozen_string_literal: true

SCRIPT_DIR = File.expand_path(File.join(File.dirname(__FILE__), '..'))
DB_DIR     = File.join(SCRIPT_DIR, 'db')

def absolute_path?(path)
  path[0, 1] == '/'
end

def archive_extension(path)
  ext = File.extname(path)
  ext = ".tar#{ext}" if path =~ /\A*\.tar\.(?:gz|bz2)\z/
  ext
end

def compare_version(a, b)
  Gem::Version.new(b) <=> Gem::Version.new(a)
end
