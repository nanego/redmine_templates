require_dependency 'issue_category'

class IssueCategory

  has_many :issue_templates, :class_name => 'IssueTemplate', :foreign_key => 'category_id', :dependent => :nullify

end