class RemoveConstraintOnTemplateTitle < ActiveRecord::Migration[5.2]
  def change
    remove_index :issue_templates, :template_title
  end
end
