# frozen_string_literal: true

# DotNetNuke CMS
class DnnCms < Fingerprinter
  include IgnorePattern::ASP
  include GithubHosted

  def downloadable_versions
    # Revision digits are ignored
    github_releases('dnnsoftware/Dnn.Platform', /DNN_Platform_(?<v>\d+\.\d+\.\d+)(?:\.\d+)?_Install\.zip\z/i)
  end
end

#
# Old Implementation, before moving to GitHub, just in case it's needed
# DotNetNuke CMS
# class DnnCms < Fingerprinter
#   include IgnorePattern::ASP
#
#   def downloadable_versions
#     # Get the latest and known versions
#     versions = (version_from_url(release_url) || {}).merge(known_versions)
#
#     Nokogiri::HTML(Typhoeus.get(release_url, request_params).body).css('td.ReleaseCell a.ReleaseLink').each do |node|
#       text = node.text.strip
#
#       next unless text =~ /\A[0-9\.]+\z/i # Ignores non stable releases
#
#       # Removes the leading 0 (07.04.00 => 7.4.0) and check if the version is already in the Hash,
#       # i.e a known version in which case we don't need to process it any further.
#       # By doing so, less requests and time are required to retrieve the list of versions
#       next if versions.key?(text.gsub(/0([0-9])/i, '\1'))
#
#       version = version_from_url(node['href'].strip)
#
#       next unless version
#
#       versions.merge!(version)
#     end
#
#     versions
#   end
#
#   # @return [ Hash ]
#   def known_versions
#     JSON.parse(File.read(File.join(DB_DIR, 'dnn_cms_known_versions.json')))
#   end
#
#   def request_params
#     {
#       followlocation: true, ssl_verifypeer: false, ssl_verifyhost: 0,
#       cookiejar: '/tmp/fingerprinter-cookies.jar',
#       cookiefile: '/tmp/fingerprinter-cookies.jar'
#     }
#   end
#
#   # @param [ String] url
#   #
#   # @return [ Hash ]
#   def version_from_url(url)
#     page = Nokogiri::HTML(Typhoeus.get(url, request_params).body)
#
#     page.css('a.FileNameLink').each do |node|
#       text = node.text.strip
#
#       next unless text =~ /\A([0-9\.]+) - New Install/i
#
#       return { Regexp.last_match[1] => download_url(node['d:fileid'], extract_nonce(page)) }
#     end
#
#     nil
#   end
#
#   # @param [ Nokogiri::HTML ]
#   #
#   # @return [ String ]
#   def extract_nonce(page)
#     page.css('input[name="__RequestVerificationToken"]').first['value']
#   end
#
#   def download_url(file_id, nonce)
#     res = Typhoeus.post(
#       'https://dotnetnuke.codeplex.com/releases/captureDownload',
#       request_params.merge(
#         body: {
#           'fileId' => file_id,
#           allowRedirectToAds: false,
#           '__RequestVerificationToken' => nonce
#         }
#       )
#     )
#
#     JSON.parse(res.body)['RedirectUrl']
#   end
#
#   def release_url
#     'https://dotnetnuke.codeplex.com/releases'
#   end
#
#   # Override to force the extension
#   # Otherwise the extraction will fail
#   def archive_extension(_url)
#     '.zip'
#   end
# end
