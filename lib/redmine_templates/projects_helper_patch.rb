require_dependency 'projects_helper'

module ProjectsHelper

  unless instance_methods.include?(:project_settings_tabs_with_templates)
    def project_settings_tabs_with_templates
      tabs = project_settings_tabs_without_templates
      templates_tab = {name: 'templates', action: :templates, partial: 'projects/settings_templates_tab', label: :label_issue_templates}
      tabs << templates_tab if ( User.current.admin? || User.current.allowed_to?(:create_issue_templates, @project) )
      tabs
    end
    alias_method_chain :project_settings_tabs, :templates
  end

end
