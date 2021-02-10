require_dependency 'projects_controller'

class ProjectsController < ApplicationController

  after_action :set_visilibity_by_template, :only => [:update]

  def set_visilibity_by_template
    if params['project']['issue_template_ids'].present?
      project_templates = IssueTemplateProject.where(project: @project)
      project_templates.each do |project_template|
        project_template.visibility = ""
        selected_function_ids = params['project']['issue_templates_functions'][project_template.issue_template_id.to_s] if params['project']['issue_templates_functions'].present?
        if selected_function_ids.present?
          function_ids = Function.where(id: selected_function_ids).pluck(:id)
          project_template.visibility = function_ids.join('|')
        end
        project_template.save
      end
    end
  end

end
