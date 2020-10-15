class AddTypologyIdToIssueTemplates < ActiveRecord::Migration[5.2]
  def self.up
    add_column :issue_templates, :typology_id, :integer, :default => nil
  end

  def self.down
    remove_column :issue_templates, :typology_id
  end
end
