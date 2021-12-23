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
end
