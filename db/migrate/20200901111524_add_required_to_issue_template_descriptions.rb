class AddRequiredToIssueTemplateDescriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_template_descriptions, :required, :boolean
  end
end
