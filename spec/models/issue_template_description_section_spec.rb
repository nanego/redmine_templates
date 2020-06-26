require "spec_helper"

describe "IssueTemplateDescriptionSection" do
  it "belongs to issue_template" do
    t = IssueTemplateDescriptionSection.reflect_on_association(:issue_template)
    expect(t.macro).to eq(:belongs_to)
  end
end