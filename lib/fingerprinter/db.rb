# Fingerprinter DB
class Fingerprinter
  def db_path
    return @db_path if @db_path

    @db_path = @options[:db] || File.join(DB_DIR, "#{app_name}.json")
    @db_path = File.expand_path(File.join(Dir.pwd, @db_path)) unless absolute_path?(@db_path)

    @db_path
  end

  def db
    File.exist?(db_path) ? JSON.parse(File.read(db_path)) || {} : {}
  end

  # return [ Array ] The sorted version numbers from the DB
  def db_versions
    versions = []

    db.each_value { |h| versions += h.values.flatten }

    versions.uniq.sort.reverse
  end

  def save_db(data)
    File.write(db_path, JSON.pretty_generate(JSON.parse(data.to_json)))
  end
end
