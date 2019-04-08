# frozen_string_literal: true

# WordPress
class Wordpress < Fingerprinter
  def downloadable_versions
    versions = {}

    json = JSON.parse(Typhoeus.get('https://api.wordpress.org/core/stable-check/1.0/').body)

    json.keys.each do |version|
      versions[version] = "http://wordpress.org/wordpress-#{version}.zip"
    end

    versions
  end

  def ignore_pattern
    %r{\A*(wp\-content/(plugins|themes).*|.php)\z}i
  end
end
