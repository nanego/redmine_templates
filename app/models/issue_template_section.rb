class IssueTemplateSection < ActiveRecord::Base

  belongs_to :issue_template_section_group

  DISPLAY_MODES = [:all_values, :selected_values_only]
  DEFAULT_ICON = "alert-fill"

  acts_as_list scope: [:issue_template_section_group_id]

  def self.editable?
    true
  end

  def rendered_value(section_attributes, textile: true, value_only: false)
    # Defined in subclasses
  end

  def value_from_boolean_attribute(attribute)
    attribute == '1' ? l(:general_text_Yes) : l(:general_text_No)
  end

  def value_from_text_attribute(attributes)
    attributes[:text].present? ? attributes[:text] : attributes[:empty_value]
  end

  def section_title(title, value = nil, textile: true)
    if textile
      "\r\n*#{title} :* #{value}\r\n"
    else
      "#{title} : #{value}"
    end
  end

  def section_item(label, inline_value = nil, textile: true)
    inline_value = " : #{inline_value} " if inline_value.present?
    if textile
      "* #{label}#{inline_value}\r\n"
    else
      "#{label}#{inline_value}"
    end
  end

  def section_basic_entry(value, textile: true)
    if textile
      "#{value}\r\n"
    else
      "#{value}"
    end
  end

end

class IssueTemplateSectionTextField < IssueTemplateSection
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

class IssueTemplateSectionCheckbox < IssueTemplateSection
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

class IssueTemplateSectionNumeric < IssueTemplateSection
  validates_presence_of :title
  before_validation :validate_single_value

  def validate_single_value
    max_value = text.to_i
    min_value = placeholder.to_i
    value = empty_value.to_i

    if value < min_value
      errors.add(self.title, ::I18n.t('activerecord.errors.messages.greater_than_or_equal_to', :count => min_value))
    end
    if value > max_value
      errors.add(self.title, ::I18n.t('activerecord.errors.messages.less_than_or_equal_to', :count => max_value))
    end

    errors
  end

  def self.short_name
    "numeric"
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

class IssueTemplateSectionTextArea < IssueTemplateSection
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

class IssueTemplateSectionDate < IssueTemplateSection
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

class IssueTemplateSectionSelect < IssueTemplateSection
  validates_presence_of :title
  before_validation :validate_buttons_with_icons_fields

  # Accessor for the buttons_with_icons attribute
  # Used for custom error message in case of validation failure
  attr_accessor :buttons_with_icons_field

  TYPES = [:checkbox, :radio, :monovalue_select, :multivalue_select, :buttons_with_icons]

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
    when "monovalue_select", "radio", "buttons_with_icons"
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

  def validate_buttons_with_icons_fields
    return if select_type != "buttons_with_icons"

    # Validate the presence of labels in the text string
    values = text.split(";", -1)
    values.each_with_index do |value, key|
      if value.blank?
        errors.add(:buttons_with_icons_field, ::I18n.t('label_value_at_index', :title => title, :key => key))
      end
    end

    # Replace empty values in the icon_name string with the default value
    icons = icon_name.split(";", -1)
    icons.each_with_index do |value, key|
      icons[key] = DEFAULT_ICON if value.blank?
    end
    self.icon_name = icons.join(";")
  end

end

class IssueTemplateSectionInstruction < IssueTemplateSection

  TYPES = ["info", "warning", "note", "comment"]

  after_initialize do
    self.instruction_type ||= "note"
  end

  validates :instruction_type, :presence => true

  def self.short_name
    "instruction"
  end

  def rendered_value(section_attributes, textile: true, value_only: false)
    if display_mode.to_i == 1
      "\n p(wiki-class-#{instruction_type}). #{text}\n"
    else
      "" # Nothing to render
    end
  end
end

# Instruction must be the last subclass (insert new class before if needed)
