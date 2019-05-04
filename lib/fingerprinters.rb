# frozen_string_literal: true

SUPPORTED_APPS = %w[
  apache-icons anchor-cms
  big-tree-cms bolt
  chamilo-lms ckeditor cms-made-simple concrete5
  django-cms dnn-cms drupal
  flatcore-cms fckeditor
  joomla
  liferay
  magento-ce mantisbt mediaelement moodle
  open-cart orchard os-commerce2
  phpmyadmin prestashop punbb
  roundcubemail
  smf
  tinymce
  umbraco
  wordpress wordpress-plugin wordpress-theme
].freeze

require 'fingerprinter'

SUPPORTED_APPS.each do |app|
  require "fingerprinters/#{app.tr('-', '_')}"
end
