class AddUniqueConstraintsToIssueTemplatesProjects < ActiveRecord::Migration[4.2]
  def self.up
    IssueTemplate.all.each do |template|
      projects = template.template_projects.uniq
      template.template_projects = []
      template.template_projects = projects
      template.save
    end
    add_index :issue_templates_projects, ["project_id", "issue_template_id"], :name=> :unique_issue_template_project , :unique => true
  end

  def self.down
    remove_index :issue_templates_projects, :name=> :unique_issue_template_project
  end
end
