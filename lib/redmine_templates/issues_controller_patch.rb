require_dependency 'issues_controller'

class IssuesController < ApplicationController

  before_action :set_template, :only => [:new]

  def set_template

    permitted_params_override = params.require(:issue).to_unsafe_h

    if params[:template_id] && params[:template_id].to_i.to_s == params[:template_id]
      @issue_template = IssueTemplate.find_by_id(params[:template_id])
      if @issue_template.present?
        @issue.safe_attributes = @issue_template.attributes.slice(*Issue.attribute_names).merge(permitted_params_override)
        @issue.project = @project
        @issue.projects = @issue_template.secondary_projects
        @issue.issue_template = @issue_template
        @issue_template.increment!(:usage)
      end
    end
  end

end
