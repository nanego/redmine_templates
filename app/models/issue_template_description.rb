class IssueTemplateDescription < ActiveRecord::Base
  belongs_to :issue_template

  # validates_presence_of :title
end
