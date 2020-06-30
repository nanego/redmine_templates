require_dependency 'issues_controller'

class IssuesController < ApplicationController

  before_action :set_template, :only => [:new]

  after_action :set_description_sections, :only => [:create]

  def set_template
    if params[:template_id] && params[:template_id].to_i.to_s == params[:template_id]
      permitted_params_override = params[:issue].present? ? params.require(:issue).to_unsafe_h : {}
      @issue_template = IssueTemplate.find_by_id(params[:template_id])
      if @issue_template.present?
        @issue.safe_attributes = @issue_template.attributes.slice(*Issue.attribute_names).merge(permitted_params_override)
        @issue.project = @project
        if Redmine::Plugin.installed?(:redmine_multiprojects_issue)
          @issue.projects = @issue_template.secondary_projects
        end
        @issue.issue_template = @issue_template
        @issue_template.increment!(:usage)
      end
    end
  end

  def set_description_sections
    if @issue.issue_template&.split_description_field?
      description_text = ""

      params[:issue][:issue_template][:sections_attributes].to_unsafe_h.each_with_index do |section, i|
        description_text += "h1. #{@issue.issue_template.sections[i].title} \r\n\r\n"
        description_text += "#{section[1][:text]}\r\n\r\n"
      end

      @issue.update(description: description_text)
    end
  end
end
