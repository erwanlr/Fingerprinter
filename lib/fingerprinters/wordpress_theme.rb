# frozen_string_literal: true

# WordPress Theme
class WordpressTheme < WordpressPlugin
  def initialize(options = {})
    # Create additional required dirs if needed
    [DB_DIR, '/tmp'].each { |dir| FileUtils.mkdir_p(File.join(dir, 'wordpress_theme')) }

    super(options)
  end

  def app_name
    "wordpress_theme/#{item_slug}"
  end

  def db_dir
    File.join(DB_DIR, 'wordpress_theme').to_s
  end

  def api_url
    format(
      'https://api.wordpress.org/themes/info/1.1/?action=theme_information&request[slug]=%s&request[fields][versions]=1',
      item_slug
    )
  end
end
