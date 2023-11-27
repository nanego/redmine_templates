require 'redmine'
require_relative 'lib/redmine_templates/hooks'

Redmine::Plugin.register :redmine_templates do
  name 'Redmine Issue Templates plugin'
  description 'This plugin add the ability to create and use issue templates.'
  author 'Vincent ROBERT'
  author_url 'mailto:contact@vincent-robert.com'
  version '0.1'
  url 'https://github.com/nanego/redmine_templates'
  requires_redmine :version_or_higher => '2.5.0'
  requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'
  requires_redmine_plugin :redmine_base_stimulusjs, :version_or_higher => '1.1.1'
  permission :create_issue_templates, {:issue_templates => [:init, :new, :create, :edit, :update, :index, :destroy]}
  permission :manage_project_issue_templates, {}
  permission :manage_issue_templates_visibility_per_project, {}
  settings :default => {'custom_fields' => [], 'disable_templates' => false},
           :partial => 'settings/redmine_plugin_templates_settings'
  menu :admin_menu, :issue_templates, {:controller => 'issue_templates', :action => 'index'},
       :caption => :label_issue_templates,
       :html => {:class => 'icon'}
end

Redmine::MenuManager.map :project_menu do |menu|
  menu.push :new_issue_sub, {:controller => 'issues', :action => 'new', :copy_from => nil},
            :param => :project_id,
            :caption => :label_other_issue,
            :html => {:accesskey => Redmine::AccessKeys.key_for(:new_issue)},
            :if => Proc.new {|p| Issue.allowed_target_trackers(p).any? &&
                p.present? &&
                p.issue_templates.present? &&
                p.issue_templates.present? &&
                (Issue.allowed_target_trackers(p) & p.issue_templates.map(&:tracker)).any?},
            :permission => :add_issues,
            :parent => :new_issue,
            :last => true
end
