module RedmineTemplates::Helpers
  module IssuesHelperPatch
    def projects_for_select_for_issue_via_template(issue, template)
      projects = projects_for_select(issue)
      projects &= template.template_projects if template.present?
      projects
    end
  end
end

IssuesHelper.prepend RedmineTemplates::Helpers::IssuesHelperPatch
ActionView::Base.send(:include, IssuesHelper)
