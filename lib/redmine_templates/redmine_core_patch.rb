#for some reasons this directory isn't added in the path when we need it
require_dependency File.expand_path('../../../app/models/issue_template', __FILE__)

require_dependency 'project'
class Project < ActiveRecord::Base

  has_many :issue_template_projects, dependent: :destroy
  has_many :issue_templates, -> { order("custom_form desc, tracker_id desc, usage desc") }, through: :issue_template_projects

  safe_attributes :issue_templates, :issue_template_ids

end

module PluginRedmineTemplates
  module ProjectPatch
    # Copies issue_templates from +project+
    def copy_issue_templates(project)
      self.issue_templates = project.issue_templates
      if Redmine::Plugin.installed?(:redmine_limited_visibility)
        project.issue_templates.each do |it|
            itp = IssueTemplateProject.where(project_id: self.id, issue_template_id: it.id).first
            itp.visibility =  IssueTemplateProject.where(project_id: project.id, issue_template_id: it.id).first.visibility
            itp.save
        end
      end
    end

    def copy(project, options={})
      super
      project = project.is_a?(Project) ? project : Project.find(project)

      to_be_copied = %w(issue_templates)

      to_be_copied = to_be_copied & Array.wrap(options[:only]) unless options[:only].nil?

      Project.transaction do
        if save
          reload

          to_be_copied.each do |name|
            send "copy_#{name}", project
          end

          save
        else
          false
        end
      end
    end
  end
end

Project.prepend PluginRedmineTemplates::ProjectPatch

require_dependency 'issue'
class Issue < ActiveRecord::Base
  belongs_to :issue_template, optional: true
  safe_attributes 'issue_template_id'
end
