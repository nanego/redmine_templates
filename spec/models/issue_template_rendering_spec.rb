# frozen_string_literal: true

require "spec_helper"

describe "IssueTemplate rendering and variable substitution" do

  fixtures :projects, :users, :trackers, :issue_statuses,
           :issue_templates, :issue_template_projects,
           :issue_template_section_groups, :issue_template_sections

  let(:template_with_sections) { IssueTemplate.find(3) }

  describe "read-only values in select sections" do
    it "correctly identifies read-only values from empty_value field" do
      section = template_with_sections.section_groups[1].sections[0]
      section.empty_value = "value1;value3"
      section.text = "value1;value2;value3"
      section.placeholder = "value2;value3"
      section.save!

      read_only_values = section.empty_value.split(';')
      all_values = section.text.split(';')

      expect(read_only_values).to contain_exactly("value1", "value3")
      expect(all_values).to contain_exactly("value1", "value2", "value3")

      writable_value = all_values - read_only_values
      expect(writable_value).to eq(["value2"])
    end
  end

  describe "button text customization" do
    let(:template_with_repeatable) { IssueTemplate.find(6) }

    it "returns default button text when not customized" do
      section_group = template_with_repeatable.section_groups.first
      section_group.add_button_title = nil
      section_group.delete_button_title = nil
      section_group.save!

      expect(section_group.add_button_title).to be_nil
      expect(section_group.delete_button_title).to be_nil
    end

    it "returns custom button text when configured" do
      section_group = template_with_repeatable.section_groups.first
      section_group.add_button_title = "Add section"
      section_group.delete_button_title = "Delete section"
      section_group.save!

      section_group.reload
      expect(section_group.add_button_title).to eq("Add section")
      expect(section_group.delete_button_title).to eq("Delete section")
    end
  end
end
