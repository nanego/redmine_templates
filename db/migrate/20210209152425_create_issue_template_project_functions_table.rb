class CreateIssueTemplateProjectFunctionsTable < ActiveRecord::Migration[5.2]
  def change
    if Redmine::Plugin.installed?(:redmine_limited_visibility)
      add_column :issue_template_projects, :visibility, :string
    end
  end
end
