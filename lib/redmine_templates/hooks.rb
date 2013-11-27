module RedmineTemplates
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("issue_templates", :plugin => "redmine_templates") +
        javascript_include_tag("issue_templates", :plugin => "redmine_templates")
    end

    # adds a link in the sidebar of the main issue page
    #(based on the redmine_better_crossprojects plugin)
    render_on :view_cross_sidebar_time_entries_bottom, :partial => 'hooks/view_issues_sidebar_queries_bottom'
  end
end
