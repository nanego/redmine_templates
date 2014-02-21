#for some reasons this directory isn't added in the path when we need it
require_dependency File.expand_path('../../../app/models/issue_template', __FILE__)

module PatchingProjectModel
  def get_issue_templates
    IssueTemplate.includes(:projects).where("projects.id" => self.id ).order("tracker_id")
  end
end
Project.send(:include, PatchingProjectModel)
