class AddUsageToIssueTemplates < ActiveRecord::Migration[4.2]
  def self.up
    add_column :issue_templates, :usage, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :issue_templates, :usage
  end
end
