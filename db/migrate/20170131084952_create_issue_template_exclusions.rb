class CreateIssueTemplateExclusions < ActiveRecord::Migration[4.2]
  def change
    unless ActiveRecord::Base.connection.table_exists? :issue_template_exclusions
      create_table :issue_template_exclusions, :id => false do |t|
        t.belongs_to :issue_template
        t.belongs_to :project
      end
      add_index :issue_template_exclusions, ["project_id", "issue_template_id"], :name=> :unique_issue_template_exclusion_per_project, :unique => true
      add_index :issue_template_exclusions, :issue_template_id
      add_index :issue_template_exclusions, :project_id
    end
  end
end
