#for some reasons this directory isn't added in the path when we need it
require_dependency File.expand_path('../../../app/models/issue_template', __FILE__)

module PatchingProjectModel
  def get_issue_templates
    IssueTemplate.includes(:projects).where("projects.id" => self.id ).order("tracker_id")
  end
  def get_activated_issue_templates
    get_issue_templates.where.not("issue_templates.id" => self.issue_template_exclusions.map(&:issue_template_id))
  end
end
Project.class_eval do
  has_many :issue_template_exclusions, dependent: :destroy
  include PatchingProjectModel
end
