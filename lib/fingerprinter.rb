require 'db'
require 'fingerprinter/archive'
require 'fingerprinter/actions'

# Fingerprinter
class Fingerprinter
  include DB

  # @param [ String ] db
  # @param [ Boolean ] db_verbose
  def initialize(db = nil, db_verbose = false)
    db ||= File.join(DB_DIR, "#{app_name}.db")
    # If the db is not an absolute path, we need to get the abslute path
    # otherwise, DataMapper will not be able to find the db
    db = File.expand_path(File.join(Dir.pwd, db)) unless absolute_path?(db)

    init_db(db, db_verbose)
  end

  def app_name
    Object.const_get(self.class.to_s).to_s.downcase
  end

  # @return [ Hash ] The versions and their download urls
  def downloadable_versions
    fail NotImplementedError
  end
end
