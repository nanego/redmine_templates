class IssueTemplatesCustomField < ActiveRecord::Base

  belongs_to :custom_field
  belongs_to :issue_template

  validates_presence_of :value

  attr_accessible :value,
                  :issue_template_id,
                  :custom_field_id

end
