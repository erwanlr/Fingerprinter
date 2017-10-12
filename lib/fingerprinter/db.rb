# Fingerprinter DB
class Fingerprinter
  def db_path
    return @db_path if @db_path

    @db_path = @options[:db] || File.join(DB_DIR, "#{app_name}.json")
    @db_path = File.expand_path(File.join(Dir.pwd, @db_path)) unless absolute_path?(@db_path)

    @db_path
  end

  def db(reload = false)
    return @db if @db && !reload

    @db = File.exist?(db_path) ? JSON.parse(File.read(db_path)) || {} : {}
  end

  # return [ Array ] The sorted version numbers from the DB
  # quite sure there is a shorter way to do that
  def db_versions
    return @db_versions if @db_versions

    versions = []

    db.each_value { |h| versions += h.values.flatten }

    @db_versions = versions.uniq.sort.reverse
  end

  def save_db(data)
    File.write(db_path, data.to_json)
  end

  # Sort the fingerpints by occurence of uniqueness
  # Meaning that files with the most amount of unique hashes
  # will be on top and checked first
  def db_sort_and_save
    save_db(
      db(true).sort_by { |_path, fp| fp.values.select { |v| v.size == 1 }.size }.reverse.to_h
    )
  end
end
