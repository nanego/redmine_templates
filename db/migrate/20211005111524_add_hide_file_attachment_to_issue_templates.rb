class AddHideFileAttachmentToIssueTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_templates, :hide_file_attachment, :boolean, default: false
  end
end
