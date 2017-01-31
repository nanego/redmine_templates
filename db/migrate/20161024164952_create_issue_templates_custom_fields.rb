class CreateIssueTemplatesCustomFields < ActiveRecord::Migration
  def change
    create_table :issue_templates_custom_fields, :id => false do |t|
      t.belongs_to :issue_template
      t.belongs_to :custom_field
      t.string :value
    end
    add_index :issue_templates_custom_fields, ["custom_field_id", "issue_template_id"], :name=> :unique_issue_template_custom_field, :unique => true
    add_index :issue_templates_custom_fields, :issue_template_id
    add_index :issue_templates_custom_fields, :custom_field_id
  end
end
