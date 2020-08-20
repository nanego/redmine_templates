class AddPlaceholderToIssueTemplateDescriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_template_descriptions, :placeholder, :string
  end
end
