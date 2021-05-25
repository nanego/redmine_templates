class AddAutocompleteSubjectToIssueTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :issue_templates, :autocomplete_subject, :boolean, default: false
  end
end
