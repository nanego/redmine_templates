class AddDescriptionToTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_templates, :template_description, :text
    add_column :issue_templates, :template_image, :string
  end
end
