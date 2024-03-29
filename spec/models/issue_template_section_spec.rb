require "spec_helper"

describe IssueTemplateSection do
  it "belongs to issue_template" do
    t = IssueTemplateSection.reflect_on_association(:issue_template_section_group)
    expect(t.macro).to eq(:belongs_to)
  end

  describe "value_from_text_attribute" do
    it "returns a text value if it's a single value" do
      t = IssueTemplateSection.new
      attributes = { text: 'a,b,c' }
      expect(t.value_from_text_attribute(attributes)).to eq("a,b,c")
    end
  end

  describe "rendered_value of instruction type when the option (Show in the generated issue) is selected" do
    it "renders the correct value" do
      section = IssueTemplateSection.new(text: 'new info', type: "IssueTemplateSectionInstruction", instruction_type: "note", display_mode: "1")
      expect(section.rendered_value([])).to eq("\n p(wiki-class-note). new info\n")
    end

    it "returns the correct wiki class" do
      IssueTemplateDescriptionInstruction::TYPES.each do |type|
        section = IssueTemplateSection.new(text: 'new info', type: "IssueTemplateSectionInstruction", instruction_type: type, display_mode: "1")
        expect(section.rendered_value([])).to include("\n p(wiki-class-#{type}). new info\n")
      end
    end
  end

  describe "rendered_value of instruction type when the option (Show in the generated issue) is unselected" do
    it "returns an empty value" do
      section = IssueTemplateSection.new(text: 'new info', type: "IssueTemplateSectionInstruction", instruction_type: "note", display_mode: "0")
      expect(section.rendered_value([])).to eq("")
    end
  end
end
