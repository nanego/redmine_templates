module RedmineTemplates
  module ProjectsControllerPatch

    def issue_template_map
      @issue_template_map ||= Rails.cache.fetch("issue_templates_by_projects-#{IssueTemplate.maximum("updated_at").to_i}") do

        templates_by_project_map = {}

        IssueTemplate.includes(:issue_template_projects).each do |template|
          template.issue_template_projects.map(&:project_id).each do |project_id|
            templates_by_project_map[project_id] ||= []
            templates_by_project_map[project_id] << template
          end
        end

        templates_by_project_map
      end
    end
  end
end

class ProjectsController < ApplicationController
  prepend RedmineTemplates::ProjectsControllerPatch

  helper_method :issue_template_map

  if Redmine::Plugin.installed?(:redmine_limited_visibility)
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
  end
end
