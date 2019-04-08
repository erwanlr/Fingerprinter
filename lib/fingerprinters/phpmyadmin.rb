# frozen_string_literal: true

# PHPMyAdmin
class Phpmyadmin < Fingerprinter
  include IgnorePattern::PHP

  def downloadable_versions
    # manual_installation_versions.merge(debian_versions)
    manual_installation_versions
  end

  #
  ## Debian Versions (not used)
  #
  def debian_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get(debian_url).body)

    page.css('a').each do |link|
      version = link.text.strip[/\Aphpmyadmin_([0-9.-]+)_all.deb\z/, 1]

      versions["#{version.gsub('-', 'deb')}-all"] = "#{debian_url}#{link.text}" if version
    end

    versions
  end

  def debian_url
    'http://ftp.ie.debian.org/debian/pool/main/p/phpmyadmin/'
  end

  #
  ## Manual Installation Versions
  #
  def manual_installation_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get('https://www.phpmyadmin.net/files/').body)

    page.css('td a').each do |link|
      version = link.text.strip[/phpMyAdmin\-([0-9\.]+)\-all\-languages\.zip\z/, 1]

      versions["#{version}-all"] = link.attr('href') if version
    end

    versions.merge(manual_installation_fixed_links)
  end

  def manual_installation_fixed_links
    {
      '1.1.0-all' => 'https://files.phpmyadmin.net/phpMyAdmin/1.1.0/phpMyAdmin_1.1.0.tar.gz',
      '1.3.0-all' => 'https://files.phpmyadmin.net/phpMyAdmin/1.3.0/phpmyadmin_1.3.0.tar.gz',
      '2.0.5-all' => 'https://files.phpmyadmin.net/phpMyAdmin/2.0.5/phpMyAdmin-2.0.5-php3.tar.gz',
      '2.1.0-all' => 'https://files.phpmyadmin.net/phpMyAdmin/2.1.0/phpMyAdmin-2.1.0-php3.tar.gz',
      '2.2.0-all' => 'https://files.phpmyadmin.net/phpMyAdmin/2.2.0/phpMyAdmin-2.1.0-php.zip'
    }
  end
end
