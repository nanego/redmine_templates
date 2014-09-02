require 'redmine'
require 'redmine_templates/hooks'
require 'redmine_templates/redmine_core_patch'

Redmine::Plugin.register :redmine_templates do
  name 'Redmine Issue Templates plugin'
  description 'This plugin add the ability to create and use issue templates.'
  author 'Vincent ROBERT'
  author_url 'mailto:contact@vincent-robert.com'
  version '0.1'
  url 'https://github.com/nanego/redmine_issue_templates'
  requires_redmine :version_or_higher => '2.5.0'
  requires_redmine_plugin :redmine_base_select2, :version_or_higher => '0.0.1'
  requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'
  permission :create_issue_templates, {:issue_templates => [:init, :new, :create, :edit, :update, :index, :destroy]}
  settings :default => { 'custom_fields' => [], 'disable_templates' => false},
           :partial => 'settings/redmine_plugin_templates_settings'
  menu :admin_menu, :issue_templates, { :controller => 'issue_templates', :action => 'index' }, :caption => :label_issue_templates
end
