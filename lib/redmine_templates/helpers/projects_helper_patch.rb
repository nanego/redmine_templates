require_dependency 'projects_helper'

module PluginRedmineTemplates
  module ProjectsHelper
    def project_settings_tabs
      super.tap do |tabs|
        if User.current.admin? || User.current.allowed_to?(:manage_project_issue_templates, @project)
          tabs << {
            name: 'issue_templates',
            action: :issue_templates,
            partial: 'projects/settings_issue_templates_tab',
            label: :label_issue_templates
          }
        end
      end
    end
  end
end

ProjectsHelper.prepend PluginRedmineTemplates::ProjectsHelper
ActionView::Base.send(:include, ProjectsHelper)
