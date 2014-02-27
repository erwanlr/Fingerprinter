require 'dm-core'
require 'dm-migrations'
require 'dm-constraints'

# Version
class Version
  include DataMapper::Resource

  has n, :fingerprints, constraint: :destroy

  property :id, Serial
  property :number, String, required: true, unique: true
end

# Path
class Path
  include DataMapper::Resource

  has n, :fingerprints, constraint: :destroy

  property :id, Serial
  property :value, String, required: true, unique: true
end

# Fingerprint
class Fingerprint
  include DataMapper::Resource

  belongs_to :version, key: true
  belongs_to :path, key: true

  property :md5_hash, String, required: true, length: 32
end

# Database Module
module DB
  def init_db(db, verbose = false)
    DataMapper::Logger.new($stdout, verbose ? :debug : :fatal)

    DataMapper.setup(:default, "sqlite://#{db}")
    DataMapper.auto_upgrade!
  end
end
