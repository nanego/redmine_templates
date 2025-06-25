class AddCreateIssuesInMainProjectToIssueTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_templates, :create_issues_in_main_project, :boolean, default: false
  end
end
