module RedmineTemplates::Helpers
  module ProjectsHelperPatch
    def project_settings_tabs
      super.tap do |tabs|
        if User.current.allowed_to?(:manage_project_issue_templates, @project) || User.current.allowed_to?(:manage_issue_templates_visibility_per_project, @project)
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

ProjectsHelper.prepend RedmineTemplates::Helpers::ProjectsHelperPatch
ActionView::Base.send(:include, ProjectsHelper)
