require_dependency 'issues_helper'

module PluginRedmineTemplates
  module IssuesHelper
  	def projects_for_select_for_issue_via_template(issue, template)
	    projects = projects_for_select(issue)	    
	    projects = template.template_projects & projects if template.present?
	    return projects 
	  end

	  def allowed_target_projects_for_issue_via_template(issue, user, current_project, template)
	  	projects = issue.allowed_target_projects(user, current_project)
	    projects = template.template_projects & projects if template.present?
	    return projects 
	  end
	end
end

IssuesHelper.prepend PluginRedmineTemplates::IssuesHelper
ActionView::Base.send(:include, IssuesHelper)