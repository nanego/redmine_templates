class MigrationSectionGroup < ActiveRecord::Base
  self.table_name = :issue_template_section_groups
end

class CreateIssueTemplateSectionGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :issue_template_section_groups do |t|
      t.string :title
      t.references :issue_template, :foreign_key => { index: true }
      t.integer :position
      t.boolean :repeatable, default: false
    end unless ActiveRecord::Base.connection.table_exists? 'issue_template_section_groups'

    up_only do
      MigrationSectionGroup.reset_column_information
      descriptions = IssueTemplateDescriptionSeparator.all + IssueTemplateDescriptionTitle.all
      descriptions.each do |separator|
        IssueTemplateSectionGroup.create!(title: separator.title,
                                          issue_template_id: separator.issue_template_id,
                                          position: separator.position,
                                          repeatable: separator.repeatable)
      end
    end
  end
end
