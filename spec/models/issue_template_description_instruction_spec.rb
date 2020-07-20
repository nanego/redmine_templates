require "spec_helper"

describe IssueTemplateDescriptionInstruction do
  it "belongs to issue_template" do
    t = IssueTemplateDescriptionInstruction.reflect_on_association(:issue_template)
    expect(t.macro).to eq(:belongs_to)
  end
end