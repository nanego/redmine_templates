module PatchingProjectModel
  def get_issue_templates
    IssueTemplate.includes(:projects).where("projects.id" => self.id )
  end
end
Project.send(:include, PatchingProjectModel)
