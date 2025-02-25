class IssueTemplateSectionGroup < ApplicationRecord

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

  def rendered_value(textile: true)
    if textile
      if title.present?
        textile_separator_with_title(title)
      else
        textile_separator
      end
    end
  end

  def textile_separator_with_title(title)
    "#{textile_separator}\r\nh2. #{title}\r\n\r\n"
  end

  def textile_separator
    "\r\n-----\r\n"
  end

  def section_is_empty?(attributes)
    persisted = attributes["id"].present?
    case attributes["type"]
    when "IssueTemplateSectionInstruction"
      empty = attributes["text"].blank?
    end
    return (!persisted && empty)
  end

end
