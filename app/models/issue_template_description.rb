class IssueTemplateDescription < ActiveRecord::Base
  belongs_to :issue_template

  # validates_presence_of :title

  def self.editable?
    true
  end
end

class IssueTemplateDescriptionDate < IssueTemplateDescription
  def self.short_name; "date" end
end

class IssueTemplateDescriptionField < IssueTemplateDescription
  def self.short_name; "field" end
end

class IssueTemplateDescriptionCheckbox < IssueTemplateDescription
  def self.short_name; "checkbox" end
end

class IssueTemplateDescriptionSection < IssueTemplateDescription
  def self.short_name; "section" end
end

class IssueTemplateDescriptionSeparator < IssueTemplateDescription
  def self.short_name; "separator" end
  def self.editable?;false end
end

class IssueTemplateDescriptionSelect < IssueTemplateDescription
  def self.short_name; "select" end
end
