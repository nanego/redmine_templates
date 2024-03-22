class AddIconToIssueTemplateSections < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_template_sections, :icon_name, :string
  end
end
