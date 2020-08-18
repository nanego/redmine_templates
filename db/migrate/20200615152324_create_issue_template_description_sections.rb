class CreateIssueTemplateDescriptionSections < ActiveRecord::Migration[5.2]
  def change
    create_table :issue_template_description_sections do |t|
      t.string :title
      t.string :description
      t.text :text
      t.references :issue_template, :foreign_key => { index: true }
    end unless ActiveRecord::Base.connection.table_exists? 'issue_template_description_sections'
  end
end
