class AddEmptyValueToIssueTemplateDescriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_template_descriptions, :empty_value, :string
  end
end
