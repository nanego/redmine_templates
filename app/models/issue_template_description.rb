class IssueTemplateDescription < ActiveRecord::Base

  belongs_to :issue_template

  def self.editable?
    true
  end

  def is_a_separator?
    false
  end

  def last?
    issue_template.descriptions.last == self || issue_template.descriptions[self.position]&.is_a_separator?
  end

  def rendered_value(section_attributes, repeatable_group_index = 0)
    # Defined in subclasses
  end

end

class IssueTemplateDescriptionField < IssueTemplateDescription
  validates_presence_of :title
  def self.short_name; "field" end

  def rendered_value(section_attributes, repeatable_group_index = 0)
    value = value_from_text_attribute(section_attributes, repeatable_group_index)
    section_title(self.title, value)
  end
end

class IssueTemplateDescriptionCheckbox < IssueTemplateDescription
  validates_presence_of :title
  def self.short_name; "checkbox" end

  def rendered_value(section_attributes, repeatable_group_index = 0)
    value = value_from_boolean_attribute(section_attributes[:text], repeatable_group_index)
    section_title(title, value)
  end
end

class IssueTemplateDescriptionSection < IssueTemplateDescription
  validates_presence_of :title
  def self.short_name; "section" end

  def rendered_value(section_attributes, repeatable_group_index = 0)
    value = value_from_text_attribute(section_attributes, repeatable_group_index)
    section_title(self.title) + textile_entry(value)
  end
end

class IssueTemplateDescriptionSeparator < IssueTemplateDescription
  def self.short_name; "separator" end
  def self.editable?;false end
  def is_a_separator?;true  end

  def rendered_value(section_attributes, repeatable_group_index = 0)
    textile_separator
  end
end

class IssueTemplateDescriptionTitle < IssueTemplateDescription
  def self.short_name; "title" end
  def is_a_separator?;true  end

  def rendered_value(section_attributes, repeatable_group_index = 0)
    textile_separator_with_title(title)
  end
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

  def rendered_value(section_attributes, repeatable_group_index = 0)
    value = value_from_text_attribute(section_attributes, repeatable_group_index)
    section_title(self.title, value)
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

  def rendered_value(section_attributes, repeatable_group_index = 0)
    case self.select_type
    when "monovalue_select", "radio"
      section_title(self.title, section_attributes[:text])
    else
      description_text = section_title(self.title)
      if self.text.present?
        if self.select_type == 'multivalue_select'
          selected_values = section_attributes['text'] || []
          selected_values.each do |selected_value|
            description_text += textile_item(selected_value)
          end
        else
          self.text.split(';').each_with_index do |value, index|
            boolean_value = value_from_boolean_attribute(section_attributes[index.to_s], repeatable_group_index)
            description_text += textile_item(value, boolean_value)
          end
        end
      end
      description_text
    end
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

  def rendered_value(section_attributes, repeatable_group_index = 0)
    '' # Nothing to render
  end
end
# Instruction must be the last subclass (insert new class before if needed)

private

def value_from_boolean_attribute(attribute, array_index)
  if attribute.is_a?(Array)
    attribute[array_index] == '1' ? l(:general_text_Yes) : l(:general_text_No)
  else
    attribute == '1' ? l(:general_text_Yes) : l(:general_text_No)
  end
end

def value_from_text_attribute(attributes, array_index)
  if attributes[:text].is_a?(Array)
    attributes[:text][array_index].present? ? attributes[:text][array_index] : attributes[:empty_value]
  else
    attributes[:text].present? ? attributes[:text] : attributes[:empty_value]
  end
end

def textile_separator_with_title(title)
  "#{textile_separator}\r\nh2. #{title}\r\n\r\n"
end

def section_title(title, value = nil)
  inline_value = value if value.present?
  "\r\n*#{title} :* #{inline_value}\r\n"
end

def textile_separator
  "\r\n-----\r\n"
end

def textile_item(label, inline_value = nil)
  inline_value = " : #{inline_value} " if inline_value.present?
  "* #{label}#{inline_value}\r\n"
end

def textile_entry(value)
  "#{value}\r\n"
end
