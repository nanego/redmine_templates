class AddShowToolbarToIssueTemplateDescriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_template_descriptions, :show_toolbar, :boolean
  end
end
