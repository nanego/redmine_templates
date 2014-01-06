class CreateIssueTemplates < ActiveRecord::Migration
  def change
    create_table :issue_templates do |t|

      t.string :template_title, :default => "", :null => false
      t.boolean :template_enabled, :default => true

      t.integer :project_id, :null => false, :default => 0
      t.string :subject, :default => "", :null => false
      t.text :description
      t.integer :tracker_id, :null => false, :default => 0
      t.integer :author_id, :null => false, :default => 0
      t.date :due_date
      t.integer :category_id
      t.integer :status_id, :default => 0, :null => false
      t.integer :assigned_to_id
      t.integer :priority_id, :default => 0, :null => false
      t.integer :fixed_version_id
      t.integer :lock_version
      t.date :start_date
      t.integer :done_ratio, :default => 0, :null => false
      t.float :estimated_hours
      t.boolean :is_private, :default => false, :null => false
      t.timestamps :created_on
      t.timestamps :update_on
    end
    add_index :issue_templates, :project_id
    add_index :issue_templates, :tracker_id
    add_index :issue_templates, :author_id
    add_index :issue_templates, :template_title, :unique => true
  end
end
