require "spec_helper"

describe IssueTemplateSectionGroup do
  it "belongs to issue_template" do
    t = IssueTemplateSectionGroup.reflect_on_association(:issue_template)
    expect(t.macro).to eq(:belongs_to)
  end
end
