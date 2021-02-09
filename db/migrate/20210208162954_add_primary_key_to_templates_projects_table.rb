class AddPrimaryKeyToTemplatesProjectsTable < ActiveRecord::Migration[5.2]
  def change
    rename_table 'issue_templates_projects', 'issue_template_projects'
    add_column :issue_template_projects, :id, :primary_key
  end
end
