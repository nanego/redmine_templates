class IssueTemplateDescription < ActiveRecord::Base
  belongs_to :issue_template

  # validates_presence_of :title

  def self.editable?
    true
  end
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

class IssueTemplateDescriptionDate < IssueTemplateDescription

  if Redmine::Plugin.installed?(:redmine_datetime_custom_field)
    TYPES = [:date, :datetime]
  else
    TYPES = [:date]
  end

  after_initialize do
    self.select_type ||= :date
  end
  validates :select_type, :presence => true

  def self.select_types_options
    TYPES.collect { |t| [ t.to_s.humanize.capitalize, t ] }
  end

  def self.short_name
    "date"
  end
end

class IssueTemplateDescriptionSelect < IssueTemplateDescription
  TYPES = [:checkbox, :radio, :monovalue_select, :multivalue_select]

  after_initialize do
    self.select_type ||= :checkbox
  end
  validates :select_type, :presence => true

  def self.select_types_options
    TYPES.collect { |t| [ t.to_s.humanize.capitalize, t ] }
  end

  def self.short_name
    "select"
  end
end
