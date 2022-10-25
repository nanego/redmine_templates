require_dependency 'issues_helper'

module PluginRedmineTemplates
  module IssuesHelper
    def projects_for_select_for_issue_via_template(issue, template)
      projects = projects_for_select(issue)
      projects &= template.template_projects if template.present?
      projects
    end
  end
end

IssuesHelper.prepend PluginRedmineTemplates::IssuesHelper
ActionView::Base.send(:include, IssuesHelper)
