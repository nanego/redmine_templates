require_dependency 'issues_controller'

class IssuesController < ApplicationController

  prepend_before_action :set_template_as_params, :only => [:new]
  append_before_action :finish_template_set_up, :only => [:new]

  append_before_action :keep_sections_values, :only => [:new, :create]
  append_before_action :update_description_with_sections, :only => [:create]
  append_before_action :update_subject_when_autocomplete, :only => [:create]

  def set_template_as_params
    if params[:template_id] && params[:template_id].to_i.to_s == params[:template_id]
      permitted_params_override = params[:issue].present? ? params.require(:issue).to_unsafe_h : {}
      @issue_template = IssueTemplate.find_by_id(params[:template_id])
      if @issue_template.present?
        params[:issue] = @issue_template.attributes.slice(*Issue.attribute_names).merge(permitted_params_override)
        params[:issue][:project_id] = params[:project_id]
      end
    end
  end

  def finish_template_set_up
    if @issue_template
      if Redmine::Plugin.installed?(:redmine_multiprojects_issue)
        @issue.projects = @issue_template.secondary_projects
      end
      @issue.issue_template = @issue_template
      @issue_template.increment!(:usage)
    end
  end

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

  def keep_sections_values
    if params[:issue].present? && params[:issue][:issue_template].present? && params[:issue][:issue_template][:descriptions_attributes].present?
      @sections_attributes = params[:issue][:issue_template][:descriptions_attributes].values
    end
  end

  def update_description_with_sections
    if @issue.issue_template&.split_description && params[:issue][:issue_template].present?

      issue_description = ""
      repeatable_group = false
      repeatable_group_size = 0
      repeatable_group_descriptions = []

      descriptions_attributes = params[:issue][:issue_template][:descriptions_attributes].values

      descriptions_attributes.each_with_index do |description_attributes, section_index|

        section = @issue.issue_template.descriptions[section_index]

        if repeatable_group
          if description_attributes[:text].is_a?(Array)
            repeatable_group_size = description_attributes[:text].size - 1
          end
          (0..repeatable_group_size).each do |repeatable_group_index|
            repeatable_group_descriptions[repeatable_group_index] ||= ""
            repeatable_group_descriptions[repeatable_group_index] += section.rendered_value(description_attributes, repeatable_group_index)
          end
        else
          issue_description += section.rendered_value(description_attributes)
        end

        repeatable_group = section.repeatable? if section.is_a_separator? # Init new repeatable group
        if repeatable_group && (section.last? || descriptions_attributes.last == description_attributes) # End current repeatable group
          repeatable_group_descriptions.each_with_index do |group_description, index|
            issue_description += textile_separator if index != 0
            issue_description += group_description
          end
          repeatable_group = false
        end
      end

      @issue.description = @issue.substituted(issue_description, @sections_attributes)
    end
  end

  def update_subject_when_autocomplete
    issue_template = @issue.issue_template
    if issue_template.present? && issue_template.autocomplete_subject && issue_template.subject.present?
      @issue.subject = @issue.substituted(issue_template.subject, @sections_attributes)
    end
  end

end
