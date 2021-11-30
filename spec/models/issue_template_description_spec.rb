require "spec_helper"

describe IssueTemplateDescription do
  it "belongs to issue_template" do
    t = IssueTemplateDescription.reflect_on_association(:issue_template)
    expect(t.macro).to eq(:belongs_to)
  end

  describe "value_from_text_attribute" do
    it "returns a text value if it's a single value" do
      t = IssueTemplateDescription.new
      attributes = { text: 'a,b,c' }
      expect(t.value_from_text_attribute(attributes, nil)).to eq("a,b,c")
    end

    it "returns a value at a specific index" do
      t = IssueTemplateDescription.new
      attributes = { text: ['a', 'b', 'c'] }
      expect(t.value_from_text_attribute(attributes, 0)).to eq("a")
      expect(t.value_from_text_attribute(attributes, 1)).to eq("b")
      expect(t.value_from_text_attribute(attributes, 2)).to eq("c")
    end

    it "returns nil if the index is out of range" do
      t = IssueTemplateDescription.new
      attributes = { text: ['a', 'b', 'c'] }
      expect(t.value_from_text_attribute(attributes, 3)).to be_nil
    end

    it "returns a value at a specfic index if the attribute is a hash" do
      t = IssueTemplateDescription.new
      attributes = { text: { '0' => 'a', '1' => 'b' } }
      expect(t.value_from_text_attribute(attributes, 0)).to eq("a")
      expect(t.value_from_text_attribute(attributes, 1)).to eq("b")
    end

  end
end
