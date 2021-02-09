#for some reasons this directory isn't added in the path when we need it
require_dependency File.expand_path('../../../app/models/issue_template', __FILE__)

require_dependency 'project'
class Project < ActiveRecord::Base

  has_many :issue_template_projects
  has_many :issue_templates, -> { order("custom_form desc, tracker_id desc, usage desc") }, through: :issue_template_projects

  safe_attributes :issue_templates, :issue_template_ids

  COPYABLES_ATTRIBUTES = %w(members wiki versions issue_categories issues queries boards documents issue_templates)

  # Copies issue_templates from +project+
  def copy_issue_templates(project)
    self.issue_templates = project.issue_templates
  end

  # Copies and saves the Project instance based on the +project+.
  # Duplicates the source project's:
  # * Wiki
  # * Versions
  # * Categories
  # * Issues
  # * Members
  # * Queries
  #
  # Accepts an +options+ argument to specify what to copy
  #
  # Examples:
  #   project.copy(1)                                    # => copies everything
  #   project.copy(1, :only => 'members')                # => copies members only
  #   project.copy(1, :only => ['members', 'versions'])  # => copies members and versions
  def copy(project, options={})
    project = project.is_a?(Project) ? project : Project.find(project)

    ##### START PATCH
    #
    to_be_copied = COPYABLES_ATTRIBUTES
    #
    ##### END PATCH

    to_be_copied = to_be_copied & Array.wrap(options[:only]) unless options[:only].nil?

    Project.transaction do
      if save
        reload

        self.attachments = project.attachments.map do |attachment|
          attachment.copy(:container => self)
        end

        to_be_copied.each do |name|
          send "copy_#{name}", project
        end
        Redmine::Hook.call_hook(:model_project_copy_before_save, :source_project => project, :destination_project => self)
        save
      else
        false
      end
    end
  end
end

require_dependency 'issue'
class Issue < ActiveRecord::Base
  belongs_to :issue_template, optional: true
  safe_attributes 'issue_template_id'
end
