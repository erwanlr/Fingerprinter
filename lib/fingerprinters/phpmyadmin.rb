
# PHPMyAdmin
class Phpmyadmin < Fingerprinter
  def downloadable_versions
    # Hash[manual_installation_versions.merge(debian_versions).to_a.sort.reverse]
    Hash[manual_installation_versions.to_a.sort.reverse]
  end

  #
  ## Debian Versions
  #
  def debian_versions
    versions = {}
    page     = Nokogiri::HTML(Typhoeus.get(debian_url).body)

    page.css('a').each do |link|
      version = link.text.strip[/\Aphpmyadmin_([0-9.-]+)_all.deb\z/, 1]

      if version
        versions["#{version.gsub('-', 'deb')}-all"] = "#{debian_url}#{link.text}"
      end
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
    page     = Nokogiri::HTML(Typhoeus.get('http://sourceforge.net/projects/phpmyadmin/files/phpMyAdmin/').body)

    page.css('a.name').each do |link|
      version = link.text.strip
      if version =~ /\A[0-9\.]+\z/
        versions["#{version}-all"] = "http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/#{version}/phpMyAdmin-#{version}-all-languages.tar.gz"
      end
    end

    versions.merge(manual_installation_fixed_links)
  end

  # 4 Versions have differents download links
  def manual_installation_fixed_links
    {
      '1.1.0-all' => 'http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/1.1.0/phpMyAdmin_1.1.0.tar.gz',
      '1.3.0-all' => 'http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/1.3.0/phpmyadmin_1.3.0.tar.gz',
      '2.0.1-all' => 'http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/2.1.0/phpMyAdmin-2.1.0-php3.tar.gz',
      '2.0.5-all' => 'http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/2.0.5/phpMyAdmin-2.0.5-php3.tar.gz'
    }
  end

  def ignore_pattern
    /\A*.php\z/
  end
end
