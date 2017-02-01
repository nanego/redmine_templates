class IssueTemplateExclusion < ActiveRecord::Base

  belongs_to :project
  belongs_to :issue_template

  attr_accessible :issue_template_id,
                  :project_id

end
