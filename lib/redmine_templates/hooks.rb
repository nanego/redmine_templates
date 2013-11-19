module RedmineTemplates
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("issue_templates", :plugin => "redmine_templates") +
        javascript_include_tag("issue_templates", :plugin => "redmine_templates")
    end
  end
end
