class AddSplitDescriptionToIssueTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_templates, :split_description, :boolean
  end
end
