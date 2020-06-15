class CreateIssueTemplateDescriptionSections < ActiveRecord::Migration[5.2]
  def change
    create_table :issue_template_description_sections do |t|
      t.string :title
      t.string :description
      t.text :text
      t.references :issue_template, :foreign_key => { index: true }
    end
  end
end
