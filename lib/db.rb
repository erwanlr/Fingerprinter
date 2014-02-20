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

  # DataMapper does not seem to support ordering by a column in a joining model
  # Solution found on StackOverflow ("DataMapper: Sorting results though association")
  def self.order_by_version(direction = :asc)
    order = DataMapper::Query::Direction.new(version.number, direction)
    query = all.query
    query.instance_variable_set('@order', [order])
    query.instance_variable_set('@links', [relationships['version'].inverse])
    all(query)
  end
end

# Database Module
module DB
  def init_db(db, verbose = false)
    DataMapper::Logger.new($stdout, verbose ? :debug : :fatal)

    DataMapper.setup(:default, "sqlite://#{db}")
    DataMapper.auto_upgrade!
  end
end
