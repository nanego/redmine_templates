require "spec_helper"

# require_relative "issue_template_section"

describe IssueTemplateSectionSelect do

  fixtures :issue_templates, :projects, :users, :issue_statuses, :trackers, :enumerations,
           :roles, :members, :member_roles, :issue_template_section_groups, :issue_template_sections, :issue_template_projects

  let!(:template_with_repeatable_sections) { IssueTemplate.find(6) }

  describe "rendered_multicheckbox_values" do

    let!(:select) { IssueTemplateSectionSelect.new }

    it "returns an empty string if no attributes" do
      expect(select.rendered_multicheckbox_values([], {})).to eq("")
    end

    it "returns simple values without negative values" do
      possible_values = ['value1', 'value2']
      attributes = { "0" => "1" }
      expect(select.rendered_multicheckbox_values(possible_values, attributes)).to eq("* value1 : Yes \r\n* value2 : No \r\n")
    end

    it "returns a values with multiple positive values" do
      possible_values = ['value1', 'value2']
      attributes = { "0" => "1", "1" => "1" }
      expect(select.rendered_multicheckbox_values(possible_values, attributes, textile: true)).to eq("* value1 : Yes \r\n* value2 : Yes \r\n")
    end

  end
end
