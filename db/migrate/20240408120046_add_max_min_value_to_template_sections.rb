class AddMaxMinValueToTemplateSections < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_template_sections, :min_value, :integer
    add_column :issue_template_sections, :max_value, :integer
  end
end