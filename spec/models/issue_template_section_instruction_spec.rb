require "spec_helper"

describe IssueTemplateSection do
  it "should add note to instruction_type if blank" do
    t = IssueTemplateSectionInstruction.new
    expect(t.instruction_type).to eq("note")
  end
end
