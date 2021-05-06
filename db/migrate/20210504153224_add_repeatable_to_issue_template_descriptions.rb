class AddRepeatableToIssueTemplateDescriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_template_descriptions, :repeatable, :boolean, default: false
  end
end
