# frozen_string_literal: true

# Fingerprinter DB
class Fingerprinter
  # TODO: Maybe create a DB class for all this stuff ?
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
  def db_versions
    return @db_versions if @db_versions

    @db_versions = []

    db.each_value do |fp|
      fp.each_value do |versions|
        versions.each do |version|
          @db_versions << version unless @db_versions.include?(version)
        end
      end
    end

    @db_versions.sort! { |a, b| compare_version(a, b) }
  end

  def save_db(data)
    File.write(db_path, data.to_json)
  end

  # Sort the fingerpints by occurence of uniqueness
  # Meaning that files with the most amount of unique hashes
  # will be on top and checked first. Versions are also sorted
  def db_sort_and_save
    fingerprints = db(true).sort_by { |_path, fp| fp.values.select { |v| v.size == 1 }.size }.reverse.to_h

    fingerprints.each_value do |hashes|
      hashes.each_value { |versions| versions.sort! { |a, b| compare_version(a, b) } }
    end

    save_db(fingerprints)
  end
end
