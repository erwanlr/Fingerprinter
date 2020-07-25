# frozen_string_literal: true

# PunBB
class Punbb < Fingerprinter
  include IgnorePattern::PHP

  def downloadable_versions
    versions = {}

    ['https://punbb.informer.com/download/museum/', 'https://punbb.informer.com/download/'].each do |repo|
      Nokogiri::HTML(Typhoeus.get(repo).body).css('a').each do |node|
        href = node['href'].strip

        next unless href =~ /\Apunbb-([0-9\.]+)\.zip\z/i

        versions[Regexp.last_match[1]] = repo + href
      end
    end

    versions
  end

  def extract_archive(archive_path, dest)
    super(archive_path, dest)

    # v1.1.x & 1.2.x contain all the files in the upload directory
    upload_dir = File.join(dest, 'upload')

    rebase(upload_dir, dest) if Dir.exist?(upload_dir)
  end
end
