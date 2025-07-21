class AddMissingIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :issue_template_descriptions, [:id, :type], if_not_exists: true
    add_index :issue_template_projects, :issue_template_id, if_not_exists: true
    add_index :issue_template_projects, :project_id, if_not_exists: true
    add_index :issue_template_sections, [:id, :type], if_not_exists: true
    add_index :issue_templates, :assigned_to_id, if_not_exists: true
    add_index :issue_templates, :category_id, if_not_exists: true
    add_index :issue_templates, :fixed_version_id, if_not_exists: true
    add_index :issue_templates, :priority_id, if_not_exists: true
    add_index :issue_templates, :status_id, if_not_exists: true
    add_index :issues, :issue_template_id, if_not_exists: true
  end
end
