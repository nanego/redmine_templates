class UpdateDescriptionSectionToAcceptAnnouncement < ActiveRecord::Migration[5.2]
  def change
  	rename_table :issue_template_description_sections, :issue_template_descriptions
  	add_column :issue_template_descriptions, :type, :string 
  end
end
