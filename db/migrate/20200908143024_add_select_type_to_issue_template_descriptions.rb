class AddSelectTypeToIssueTemplateDescriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_template_descriptions, :select_type, :string
  end
end
