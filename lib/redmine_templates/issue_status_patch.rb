module RedmineTemplates::IssueStatusPatch

  def self.prepended(base)
    base.has_many :issue_templates, :foreign_key => 'status_id'
    base.before_destroy :set_default_status_id_in_issue_templates
  end

  def set_default_status_id_in_issue_templates
    IssueTemplate.where('status_id = ?', id).update_all('status_id = 0')
  end

end
IssueStatus.prepend RedmineTemplates::IssueStatusPatch
