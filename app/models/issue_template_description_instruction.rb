class IssueTemplateDescriptionInstruction < IssueTemplateDescription
  after_initialize do
    self.instruction_type ||= "note"
  end

  validates :instruction_type, :presence => true

  def self.instruction_types_options
    ["info", "warning", "note"].collect { |t| [ t.capitalize, t ] }
  end

  def editable
    false
  end
end
