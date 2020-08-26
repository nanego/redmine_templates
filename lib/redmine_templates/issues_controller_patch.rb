require_dependency 'issues_controller'

class IssuesController < ApplicationController

  before_action :set_template, :only => [:new]

  append_before_action :update_description_with_sections, :only => [:create]

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

  def update_description_with_sections
    if @issue.issue_template&.split_description && params[:issue][:issue_template].present?
      description_text = ""
      descriptions_attributes = params[:issue][:issue_template][:descriptions_attributes].values
      descriptions_attributes.each_with_index do |description, i|
        split_item = @issue.issue_template.descriptions[i]
        unless split_item.is_a? IssueTemplateDescriptionInstruction
          description_text += "h2. #{split_item.title} \r\n\r\n"
          if description[:text].present?
            value = description[:text]
          else
            value = description[:placeholder]
          end
          description_text += "#{value}\r\n\r\n"
        end
        @issue.description = description_text
      end
    end
  end
end
