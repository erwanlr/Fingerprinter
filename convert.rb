require 'dm-core'
require 'dm-migrations'
require 'dm-constraints'
require 'dm-sqlite-adapter'
require 'json'

# require_relative 'lib/fingerprinters'

QUERY_ALL = 'SELECT md5_hash, path_id, version_id, ' \
             'versions.number AS version,' \
             'paths.value AS path ' \
             'FROM fingerprints ' \
             'LEFT JOIN versions ON version_id = versions.id ' \
             'LEFT JOIN paths on path_id = paths.id ' \
             'ORDER BY version DESC'.freeze
# Version
class Version
  include DataMapper::Resource

  storage_names[:default] = 'versions'

  has n, :fingerprints, constraint: :destroy

  property :id, Serial
  property :number, String, required: true, unique: true
end

# Path
class Path
  include DataMapper::Resource

  storage_names[:default] = 'paths'

  has n, :fingerprints, constraint: :destroy

  property :id, Serial
  property :value, String, required: true, unique: true
end

# Fingerprint
class Fingerprint
  include DataMapper::Resource

  storage_names[:default] = 'fingerprints'

  belongs_to :version, key: true
  belongs_to :path, key: true

  property :md5_hash, String, required: true, length: 32
end

%w[punbb].each do |app|
  slug = app.tr('-', '_')

  db_file = File.join(Dir.pwd, 'db', "#{slug}.db")

  puts "Converting #{app} (#{db_file})"

  raise "#{db_file} Doesn't exist" unless File.exist?(db_file)

  DataMapper.setup(:default, "sqlite://#{db_file}")
  DataMapper.auto_upgrade!

  fingerprints = {}

  repository(:default).adapter.select(QUERY_ALL).each do |f|
    fingerprints[f.path] ||= {}
    fingerprints[f.path][f.md5_hash] ||= []
    fingerprints[f.path][f.md5_hash] << f.version
  end

  # File.write(File.join(Dir.pwd, 'db', "#{slug}.json"), fingerprints.to_json)
  File.write(File.join(Dir.pwd, 'db', "#{slug}.json"), JSON.pretty_generate(JSON.parse(fingerprints.to_json)))
end
