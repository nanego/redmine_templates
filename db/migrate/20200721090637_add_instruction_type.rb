class AddInstructionType < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_template_descriptions, :instruction_type, :string
  end
end
