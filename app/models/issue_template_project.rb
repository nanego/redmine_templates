class IssueTemplateProject < ActiveRecord::Base

  belongs_to :issue_template
  belongs_to :project

end
