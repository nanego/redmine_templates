class IssueTemplateSectionGroup < ActiveRecord::Base

  belongs_to :issue_template
  has_many :sections, -> { order(:position) }, :class_name => 'IssueTemplateSection', :dependent => :destroy
  accepts_nested_attributes_for :sections, :reject_if => :section_is_empty?, :allow_destroy => true

  def self.editable?
    true
  end

  def is_a_separator?
    true
  end

  def self.short_name
    "section_group"
  end

  def rendered_value(section_attributes, repeatable_group_index = 0, textile: true, value_only: false)
    if textile
      if title.present?
        textile_separator_with_title(title)
      else
        textile_separator
      end
    end
  end

  def section_is_empty?(attributes)
    persisted = attributes["id"].present?
    case attributes["type"]
    when IssueTemplateSectionInstruction.name
      empty = attributes["text"].blank?
    end
    return (!persisted && empty)
  end

end
