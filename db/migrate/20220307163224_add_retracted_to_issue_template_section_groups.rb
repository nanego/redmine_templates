class AddRetractedToIssueTemplateSectionGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_template_section_groups, :retracted, :boolean, default: false
  end
end
