class AddShowOnOverviewToTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_templates, :show_on_overview, :boolean, :default => false, :null => false
  end
end
