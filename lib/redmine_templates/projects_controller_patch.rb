require_dependency 'projects_controller'

class ProjectsController < ApplicationController

  after_action :set_visilibity_by_template, :only => [:update]

  def set_visilibity_by_template
    if User.current.allowed_to?(:manage_issue_templates_visibility_per_project, @project)
      if params['project'].present? && params['project']['issue_templates_functions'].present?
        project_templates = IssueTemplateProject.where(project: @project)
        project_templates.each do |project_template|
          project_template.visibility = ""
          selected_function_ids = params['project']['issue_templates_functions'][project_template.issue_template_id.to_s]
          if selected_function_ids.present?
            function_ids = Function.where(id: selected_function_ids).pluck(:id)
            project_template.visibility = function_ids.join('|')
          end
          project_template.save
        end
      end
    end
  end

  def issue_template_map
    @issue_template_map ||= Rails.cache.fetch("issue_templates-#{IssueTemplate.maximum("created_at").to_i}") do
      
      templates_by_project_map = {}

      @entries.each do |p|
        issue_templates = p.send("issue_templates")
        templates_by_project_map[p.id] = issue_templates.pluck(:template_title).compact.join(', ').html_safe
      end
      templates_by_project_map

    end 
  end

  helper_method :issue_template_map

end
