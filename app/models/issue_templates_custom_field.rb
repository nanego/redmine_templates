class IssueTemplatesCustomField < ApplicationRecord
  include Redmine::SafeAttributes

  belongs_to :custom_field
  belongs_to :issue_template

  validates_presence_of :value

  safe_attributes :value,
                  :issue_template_id,
                  :custom_field_id

end
