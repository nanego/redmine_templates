require "spec_helper"

describe IssueTemplateDescriptionSelect do

  fixtures :issue_templates, :projects, :users, :issue_statuses, :trackers, :enumerations,
           :roles, :members, :member_roles, :issue_template_descriptions, :issue_template_projects

  let!(:template_with_repeatable_sections) { IssueTemplate.find(6) }

  it "belongs to issue_template" do
    t = IssueTemplateDescriptionSelect.reflect_on_association(:issue_template)
    expect(t.macro).to eq(:belongs_to)
  end

  describe "rendered_multicheckbox_values" do

    let!(:select) { IssueTemplateDescriptionSelect.new }

    it "returns an empty string if no attributes" do
      expect(select.rendered_multicheckbox_values([], {}, nil)).to eq("")
    end

    it "returns simple values without repeatable groups" do
      possible_values = ['value1', 'value2']
      attributes = { "0" => "1" }
      expect(select.rendered_multicheckbox_values(possible_values, attributes, nil)).to eq("* value1 : Yes \r\n* value2 : No \r\n")
    end

    it "returns a value for a repeatable group" do
      possible_values = ['value1', 'value2']
      attributes = { "values" => { "firstgroup" => { "0" => "1" } } }
      expect(select.rendered_multicheckbox_values(possible_values, attributes, 0)).to eq("* value1 : Yes \r\n* value2 : No \r\n")
    end

  end
end
