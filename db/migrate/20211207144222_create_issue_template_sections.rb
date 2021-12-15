class MigrationSection < ActiveRecord::Base
  self.table_name = :issue_template_sections
end

class CreateIssueTemplateSections < ActiveRecord::Migration[5.2]
  def change
    create_table :issue_template_sections do |t|
      t.string :title
      t.references :issue_template_section_group, index: { name: 'index_issue_template_sections_on_section_group_id' }
      t.integer :position
      t.string :description
      t.text :text
      t.string :type
      t.string :instruction_type
      t.string :placeholder
      t.boolean :show_toolbar
      t.boolean :required
      t.string :empty_value
      t.string :select_type
      t.string :display_mode
    end unless ActiveRecord::Base.connection.table_exists? 'issue_template_sections'

    up_only do
      MigrationSection.reset_column_information
      templates = IssueTemplate.all
      templates.each do |template|
        group = IssueTemplateSectionGroup.new(issue_template_id: template.id, position: 1, repeatable: false)
        template.descriptions.each do |description|
          if description.is_a?(IssueTemplateDescriptionSeparator) || description.is_a?(IssueTemplateDescriptionTitle)
            group = IssueTemplateSectionGroup.where(issue_template_id: template.id,
                                                    position: description.position).first
          else

            new_type = ""
            case description.type
            when 'IssueTemplateDescriptionField'
              new_type = 'IssueTemplateSectionTextField'
            when 'IssueTemplateDescriptionCheckbox'
              new_type = 'IssueTemplateSectionCheckbox'
            when 'IssueTemplateDescriptionSection'
              new_type = 'IssueTemplateSectionTextArea'
            when 'IssueTemplateDescriptionDate'
              new_type = 'IssueTemplateSectionDate'
            when 'IssueTemplateDescriptionInstruction'
              new_type = 'IssueTemplateSectionInstruction'
            when 'IssueTemplateDescriptionSelect'
              new_type = 'IssueTemplateSectionSelect'
            end

            section = IssueTemplateSection.new
            section.title = description.title
            section.description = description.description
            section.text = description.text
            section.type = new_type
            section.instruction_type = description.instruction_type
            section.placeholder = description.placeholder
            section.show_toolbar = description.show_toolbar
            section.required = description.required
            section.empty_value = description.empty_value
            section.select_type = description.select_type
            section.display_mode = description.display_mode
            section.position = description.position
            section.issue_template_section_group = group
            section.save!
          end
        end
      end
    end
  end
end
