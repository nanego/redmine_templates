require_dependency 'issue_status'

class IssueStatus

  has_many :issue_templates

  before_destroy :set_default_status_id_in_issue_templates

  def set_default_status_id_in_issue_templates
    IssueTemplate.where('status_id = ?', id).update_all('status_id = 0')    
  end

end