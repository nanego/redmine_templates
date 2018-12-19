class IssueTemplateExclusion < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :project
  belongs_to :issue_template

  safe_attributes :issue_template_id,
                  :project_id

end
