require 'redmine'
require 'redmine_templates/hooks'
require 'redmine_templates/redmine_core_patch'

# Little hack for deface in redmine:
# - redmine plugins are not railties nor engines, so deface overrides are not detected automatically
# - deface doesn't support direct loading anymore ; it unloads everything at boot so that reload in dev works
# - hack consists in adding "app/overrides" path of the plugin in Redmine's main #paths
Rails.application.paths["app/overrides"] ||= []
Rails.application.paths["app/overrides"] << File.expand_path("../app/overrides", __FILE__)

Redmine::Plugin.register :redmine_templates do
  name 'Redmine Issue Templates plugin'
  description 'This plugin add the ability to create and use issue templates.'
  author 'Vincent ROBERT'
  author_url 'mailto:contact@vincent-robert.com'
  version '0.1'
  url 'https://github.com/nanego/redmine_issue_templates'
  requires_redmine :version_or_higher => '2.2.0'
  permission :create_issue_templates, {:issue_templates => [:new, :create]}
end
