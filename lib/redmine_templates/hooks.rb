module RedmineTemplates
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("issue_templates", :plugin => "redmine_templates") +
        javascript_include_tag("issue_templates", :plugin => "redmine_templates")
    end

    # adds a link in the sidebar of the main issue page
    render_on :view_issues_sidebar_queries_bottom, :partial => 'hooks/view_sidebar_manage_templates'
  end

  class ModelHook < Redmine::Hook::Listener
    def after_plugins_loaded(_context = {})
      require_relative 'menu_manager_patch'
      require_relative 'issues_controller_patch'
      require_relative 'projects_controller_patch'
      require_relative 'issue_patch'
      require_relative 'project_query_patch'
      require_relative 'queries_helper_patch'
      require_relative 'issue_query_patch'
      require_relative 'tracker_patch'
      require_relative 'issue_status_patch'
      require_relative 'issue_category_patch'
      require_relative 'user_patch'
      require_relative 'issue_priority_patch'
      require_relative 'typology_patch' if Redmine::Plugin.installed?(:redmine_typologies)
      require_relative 'helpers/projects_helper_patch'
      require_relative 'helpers/issues_helper_patch'
      require_relative 'helpers/application_helper_patch'
      require_relative 'project_patch'
    end
  end
end
