class IssueTemplateProject < ApplicationRecord

  belongs_to :issue_template
  belongs_to :project

end
