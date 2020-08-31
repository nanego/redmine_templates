class IssueTemplateDescription < ActiveRecord::Base
  belongs_to :issue_template

  # validates_presence_of :title

  def editable
    true
  end
end

class IssueTemplateDescriptionDate < IssueTemplateDescription
end

class IssueTemplateDescriptionField < IssueTemplateDescription
end

class IssueTemplateDescriptionCheckbox < IssueTemplateDescription
end

class IssueTemplateDescriptionSection < IssueTemplateDescription
end

class IssueTemplateDescriptionSeparator < IssueTemplateDescription
end
