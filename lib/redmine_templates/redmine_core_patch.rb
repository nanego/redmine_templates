#for some reasons this directory isn't added in the path when we need it
require_dependency File.expand_path('../../../app/models/issue_template', __FILE__)

module PatchingProjectModel

  def get_issue_templates
    IssueTemplate.includes(:projects).where("projects.id" => self.id ).order("tracker_id")
  end

  def get_activated_issue_templates
    get_issue_templates.where.not("issue_templates.id" => self.issue_template_exclusions.map(&:issue_template_id))
  end

  def update_all_issue_templates
    IssueTemplate.all.each do |template|
      template.update_projects_through_custom_fields
      template.save
    end
  end

end

Project.class_eval do

  has_many :issue_template_exclusions, dependent: :destroy

  after_save :update_all_issue_templates

  include PatchingProjectModel

end
