class AddDisplayModeToIssueTemplateDescriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_template_descriptions, :display_mode, :string
  end
end
