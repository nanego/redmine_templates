class DropIssueTemplateExclusions < ActiveRecord::Migration[4.2]
  def change
    drop_table :issue_template_exclusions
  end
end
