# frozen_string_literal: true

require "spec_helper"

describe "IssueTemplate section management" do

  fixtures :projects, :users, :issues,
           :issue_templates, :issue_template_projects,
           :issue_template_section_groups, :issue_template_sections

  let(:template_with_sections) { IssueTemplate.find(3) }
  let(:template_with_repeatable_sections) { IssueTemplate.find(6) }

  describe "read-only values in list of values" do
    it "saves read-only values in empty_data column" do
      template = IssueTemplate.find(1)
      section_group = template.section_groups.create!(title: "Test group", position: 1)
      section = section_group.sections.create!(
        type: "IssueTemplateSectionSelect",
        title: "list test",
        position: 1,
        text: "val_1;val_2;val_3",
        placeholder: "val_1;val_2",
        empty_value: "val_1;val_3"
      )

      expect(section.empty_value).to eq("val_1;val_3")
      expect(section.placeholder).to eq("val_1;val_2")
      expect(section.text).to eq("val_1;val_2;val_3")
    end
  end

  describe "repeatable section button titles" do
    it "stores custom add and delete button titles" do
      section_group = IssueTemplateSectionGroup.find_by(issue_template_id: template_with_repeatable_sections.id)
      
      section_group.add_button_title = "Add section"
      section_group.delete_button_title = "Delete section"
      expect(section_group.save).to be_truthy

      section_group.reload
      expect(section_group.add_button_title).to eq("Add section")
      expect(section_group.delete_button_title).to eq("Delete section")
    end

    it "does not require button titles for non-repeatable sections" do
      section_group = template_with_sections.section_groups.first
      expect(section_group.repeatable).to be_falsey
      expect(section_group.add_button_title).to be_nil
      expect(section_group.delete_button_title).to be_nil
    end

    it "allows button titles when section is marked as repeatable" do
      template = IssueTemplate.find(1)
      section_group = template.section_groups.first || template.section_groups.create!(position: 1)
      
      section_group.repeatable = true
      section_group.add_button_title = "Custom Add"
      section_group.delete_button_title = "Custom Delete"
      
      expect(section_group.save).to be_truthy
      section_group.reload
      expect(section_group.add_button_title).to eq("Custom Add")
      expect(section_group.delete_button_title).to eq("Custom Delete")
    end
  end
end
