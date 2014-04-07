class AddUsageToIssueTemplates < ActiveRecord::Migration
  def self.up
    add_column :issue_templates, :usage, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :issue_templates, :usage
  end
end
