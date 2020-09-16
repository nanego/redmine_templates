require "spec_helper"

describe IssueTemplateDescription do
  it "belongs to issue_template" do
    t = IssueTemplateDescriptionInstruction.reflect_on_association(:issue_template)
    expect(t.macro).to eq(:belongs_to)
  end

  it "should add note to instruction_type if blank" do
    t = IssueTemplateDescriptionInstruction.new
    expect(t.instruction_type).to eq("note")
  end
end
