require_dependency 'issues_controller'

class IssuesController < ApplicationController

  before_action :set_template, :only => [:new]

  def set_template
    if params[:template_id] && params[:template_id].to_i.to_s == params[:template_id]
      @issue_template = IssueTemplate.find_by_id(params[:template_id])
    end
  end

end
