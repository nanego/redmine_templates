class CreateIssueTemplatesProjects < ActiveRecord::Migration[4.2]
  def change
    create_table :issue_templates_projects, :id => false do |t|
      t.belongs_to :issue_template
      t.belongs_to :project
    end
  end
end
