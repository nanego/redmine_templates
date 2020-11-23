class IssueTemplateDescription < ActiveRecord::Base

  belongs_to :issue_template

  def self.editable?
    true
  end

  def is_a_separator?
    false
  end
end

class IssueTemplateDescriptionField < IssueTemplateDescription
  validates_presence_of :title
  def self.short_name; "field" end
end

class IssueTemplateDescriptionCheckbox < IssueTemplateDescription
  validates_presence_of :title
  def self.short_name; "checkbox" end
end

class IssueTemplateDescriptionSection < IssueTemplateDescription
  validates_presence_of :title
  def self.short_name; "section" end
end

class IssueTemplateDescriptionSeparator < IssueTemplateDescription
  def self.short_name; "separator" end
  def self.editable?;false end
  def is_a_separator?;true  end
end

class IssueTemplateDescriptionTitle < IssueTemplateDescription
  def self.short_name; "title" end
  def self.editable?;false end
  def is_a_separator?;true  end
end

class IssueTemplateDescriptionDate < IssueTemplateDescription
  validates_presence_of :title

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
  validates_presence_of :title

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

class IssueTemplateDescriptionInstruction < IssueTemplateDescription

  TYPES = ["info", "warning", "note", "comment"]

  after_initialize do
    self.instruction_type ||= "note"
  end

  validates :instruction_type, :presence => true

  def self.short_name
    "instruction"
  end
end
# Instruction must be the last subclass (insert new class before if needed)
