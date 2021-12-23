class IssueTemplateDescription < ActiveRecord::Base

  belongs_to :issue_template

  DISPLAY_MODES = [:all_values, :selected_values_only]

  validates_presence_of :position
  acts_as_list scope: [:issue_template_id]

  def self.editable?
    true
  end

  def is_a_separator?
    false
  end

  def last?
    issue_template.descriptions.last == self || issue_template.descriptions[self.position]&.is_a_separator?
  end

  def rendered_value(section_attributes, textile: true, value_only: false)
    # Defined in subclasses
  end

end

class IssueTemplateDescriptionField < IssueTemplateDescription
  validates_presence_of :title

  def self.short_name
    "field"
  end

  def rendered_value(section_attributes, textile: true, value_only: false)
    value = value_from_text_attribute(section_attributes)
    if value_only
      section_basic_entry(value, textile: textile)
    else
      section_title(title, value, textile: textile)
    end

  end
end

class IssueTemplateDescriptionCheckbox < IssueTemplateDescription
  validates_presence_of :title

  def self.short_name
    "checkbox"
  end

  def rendered_value(section_attributes, textile: true, value_only: false)
    value = value_from_boolean_attribute(section_attributes[:text])
    if value_only
      section_basic_entry(value, textile: textile)
    else
      section_title(title, value, textile: textile)
    end
  end
end

class IssueTemplateDescriptionSection < IssueTemplateDescription
  validates_presence_of :title

  def self.short_name
    "section"
  end

  def rendered_value(section_attributes, textile: true, value_only: false)
    value = value_from_text_attribute(section_attributes)
    if value_only
      section_basic_entry(value, textile: textile)
    else
      section_title(title, textile: textile) + section_basic_entry(value, textile: textile)
    end
  end
end

class IssueTemplateDescriptionSeparator < IssueTemplateDescription
  def self.short_name
    "separator"
  end

  def self.editable?
    false
  end

  def is_a_separator?
    true
  end

  def rendered_value(section_attributes, textile: true, value_only: false)
    textile_separator if textile
  end
end

class IssueTemplateDescriptionTitle < IssueTemplateDescription
  def self.short_name
    "title"
  end

  def is_a_separator?
    true
  end

  def rendered_value(section_attributes, textile: true, value_only: false)
    textile_separator_with_title(title) if textile
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
    TYPES.collect { |t| [t.to_s.humanize.capitalize, t] }
  end

  def self.short_name
    "date"
  end

  def rendered_value(section_attributes, textile: true, value_only: false)
    value = value_from_text_attribute(section_attributes)
    if value_only
      section_basic_entry(value, textile: textile)
    else
      section_title(title, value, textile: textile)
    end

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
    TYPES.collect { |t| [t.to_s.humanize.capitalize, t] }
  end

  def self.short_name
    "select"
  end

  def rendered_value(section_attributes, textile: true, value_only: false)
    case self.select_type
    when "monovalue_select", "radio"
      value = value_from_text_attribute(section_attributes)
      if value_only
        section_basic_entry(value, textile: textile)
      else
        section_title(title, value, textile: textile)
      end
    else
      description_text = value_only ? "" : section_title(title, textile: textile)
      if self.text.present?
        if self.select_type == 'multivalue_select'
          # MultiValueSelect
          selected_values = section_attributes[:text] || []
          selected_values.each do |selected_value|
            description_text += section_item(selected_value, textile: textile)
          end
        else
          # MultiCheckboxes
          possible_values = self.text.split(';')
          description_text += rendered_multicheckbox_values(possible_values, section_attributes, textile: textile)
        end
      end
      description_text
    end
  end

  def rendered_multicheckbox_values(possible_values, section_attributes, textile: true)
    description_text = ""
    attributes = section_attributes.values

    possible_values.each_with_index do |value, index|
      boolean_value = value_from_boolean_attribute(attributes[index])
      unless value_hidden_by_display_mode(boolean_value)
        description_text += section_item(value, boolean_value, textile: textile)
      end
    end

    description_text
  end

  def value_hidden_by_display_mode(boolean_value)
    self.display_mode == "selected_values_only" && boolean_value == l(:general_text_No)
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

  def rendered_value(section_attributes, textile: true, value_only: false)
    '' # Nothing to render
  end
end

# Instruction must be the last subclass (insert new class before if needed)
