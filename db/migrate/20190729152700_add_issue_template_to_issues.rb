class AddIssueTemplateToIssues < ActiveRecord::Migration[5.2]
  def change
    add_column :issues, :issue_template_id, :integer,
               :default => nil, :null => true
  end
end
