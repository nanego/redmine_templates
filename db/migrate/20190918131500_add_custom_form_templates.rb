class AddCustomFormTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_templates, :custom_form, :boolean, :default => false
    add_column :issue_templates, :custom_form_path, :text, :default => nil, :null => true
  end
end
