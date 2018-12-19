class AddAuthorizedViewersToIssueTemplates < ActiveRecord::Migration[4.2]
  def self.up
    add_column :issue_templates, :authorized_viewers, :text
  end

  def self.down
    remove_column :issue_templates, :authorized_viewers
  end
end
