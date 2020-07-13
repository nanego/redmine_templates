class MigrationDescriptionSection < ActiveRecord::Base
  self.table_name = :issue_template_description_sections
end

class UpdateDescriptionSectionToAcceptAnnouncement < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_template_description_sections, :type, :string

    up_only do
        MigrationDescriptionSection.reset_column_information
        MigrationDescriptionSection.find_each do |section|
            section.update!(type: IssueTemplateDescriptionSection)
        end
    end

    rename_table :issue_template_description_sections, :issue_template_descriptions
  end
end
