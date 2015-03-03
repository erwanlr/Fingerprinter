
# PunBB
class Punbb < Fingerprinter
  include Experimental
  include IgnorePattern::PHP

  def downloadable_versions
    versions = {}

    ['http://punbb.informer.com/download/museum/', 'http://punbb.informer.com/download/'].each do |repo|
      Nokogiri::HTML(Typhoeus.get(repo).body).css('td a').each do |node|
        href = node['href'].strip

        next unless href =~ /\Apunbb-([0-9\.]+)\.zip\z/i

        versions[Regexp.last_match[1]] = repo + href
      end
    end

    versions
  end
end
