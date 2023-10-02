class AddPersonalizedButtonTitleToIssueTemplateSectionGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_template_section_groups, :add_button_title, :string
    add_column :issue_template_section_groups, :delete_button_title, :string
  end
end