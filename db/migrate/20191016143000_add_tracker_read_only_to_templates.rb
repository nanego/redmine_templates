class AddTrackerReadOnlyToTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_templates, :tracker_read_only, :boolean, :default => false, :null => false
  end
end
