# WordPress Plugin
class WordpressPlugin < Fingerprinter
  include IgnorePattern::PHP

  def initialize(options = {})
    # Create additional required dirs if needed
    [DB_DIR, '/tmp'].each { |dir| FileUtils.mkdir_p(File.join(dir, 'wordpress_plugin')) }

    super(options)
  end

  def app_name
    "wordpress_plugin/#{plugin_slug}"
  end

  def plugin_slug
    @options[:app_params]
  end

  def plugin_data
    @plugin_data ||= JSON.parse(
      Typhoeus.get(
        format(
          'https://api.wordpress.org/plugins/info/1.1/?action=plugin_information&request[slug]=%s',
          plugin_slug
        )
      ).body
    )
  end

  def downloadable_versions
    versions = {}

    return {} if plugin_data.nil? # Case when the plugin has been removed from WP
    
    versions[plugin_data['version']] = plugin_data['download_link']

    plugin_data['versions'].each do |version, download_link|
      next unless version =~ /\A[0-9\.]+\z/ # Only Stables

      versions[version] = download_link
    end

    versions
  end
end
