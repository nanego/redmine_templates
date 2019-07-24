class MultiprojectsIssueTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :multiprojects_issue_templates, :id => false do |t|
      t.belongs_to :issue_template
      t.belongs_to :project
    end
    add_index :multiprojects_issue_templates, [:issue_template_id, :project_id], :unique => true, name: "unique_multiproject_issue_template"
    add_column :issue_templates, :answers_on_secondary_projects, :boolean,
               :default => true, :null => false
  end
end
