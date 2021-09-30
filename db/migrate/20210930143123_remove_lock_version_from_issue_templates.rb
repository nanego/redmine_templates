class RemoveLockVersionFromIssueTemplates < ActiveRecord::Migration[5.2]
  def change
    remove_column :issue_templates, :lock_version, :integer
  end
end
