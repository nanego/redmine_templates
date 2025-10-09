require "spec_helper"
require "active_support/testing/assertions"
require_relative "../support/system_test_helpers"

RSpec.describe "creating issues with templates", type: :system do
  include ActiveSupport::Testing::Assertions
  include IssuesHelper

  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
           :trackers, :projects_trackers, :enabled_modules, :issue_statuses, :issues,
           :enumerations, :custom_fields, :custom_values, :custom_fields_trackers,
           :watchers, :journals, :journal_details, :versions,
           :workflows, :issue_templates, :issue_template_projects, :issue_template_section_groups, :issue_template_sections

  let(:template_with_sections) { IssueTemplate.find(3) }
  let(:template_4) { IssueTemplate.find(4) }
  let(:template_with_repeatable_sections) { IssueTemplate.find(6) }
  let(:project) { Project.find(2) }

  before do
    log_user('jsmith', 'jsmith')
  end

  describe "templates with sections and instructions" do
    it "shows an issue form with sections fields instead of description field" do
      visit new_issue_path(project_id: project.identifier, template_id: template_with_sections.id)

      expect(page).to have_field('Subject', with: 'Issue created with template 3')
      expect(page).to_not have_selector("description")
      expect(page).to have_selector('#issue_issue_template_section_groups_attributes_1_0_sections_attributes_1_text', text: "Type here first section content")
      expect(page).to have_selector('#issue_issue_template_section_groups_attributes_1_0_sections_attributes_2_text', text: "Type here second section content")
      expect(page).to have_selector('#attachments_form')

      fill_in 'issue_issue_template_section_groups_attributes_1_0_sections_attributes_7_text', with: 'One-line edited content'
      fill_in 'issue_issue_template_section_groups_attributes_1_0_sections_attributes_8_text', with: "01/01/2025"

      click_on 'Create'

      expect(page).to have_content('created', wait: true)

      expect(page).to have_selector('.description', text: "Type here first section content")
      expect(page).to have_selector('.description', text: "Type here second section content")
      expect(page).to have_selector('.description', text: 'One-line edited content')
      expect(page).to have_selector('.description', text: "2025-01-01")
    end

    it "keeps sections values when form is reloaded" do
      visit new_issue_path(project_id: project.identifier, template_id: template_with_sections.id)

      expect(page).to have_field('Subject', with: 'Issue created with template 3')
      expect(page).to_not have_selector("description")
      expect(page).to_not have_selector("status")
      expect(page).to have_selector('#issue_issue_template_section_groups_attributes_1_0_sections_attributes_1_text', text: "Type here first section content")
      expect(page).to have_selector('#issue_issue_template_section_groups_attributes_1_0_sections_attributes_2_text', text: "Type here second section content")

      fill_in 'issue_issue_template_section_groups_attributes_1_0_sections_attributes_1_text', with: 'Edited text area'
      fill_in 'issue_issue_template_section_groups_attributes_1_0_sections_attributes_7_text', with: 'One-line edited content'
      fill_in 'issue_issue_template_section_groups_attributes_1_0_sections_attributes_8_text', with: Date.current.strftime('%d/%m/%Y')

      select "Feature request", :from => "issue_tracker_id"

      # Auto-reload happens here

      expect(page).to have_selector("#issue_status_id")

      expect(page).to have_selector('#issue_issue_template_section_groups_attributes_1_0_sections_attributes_2_text', text: "Type here second section content")
      expect(page).to have_selector('#issue_issue_template_section_groups_attributes_1_0_sections_attributes_1_text', text: 'Edited text area')
      # expect(page).to have_selector('#issue_issue_template_section_groups_attributes_1_0_sections_attributes_7_text', text: 'One-line edited content')

    end

    it "shows disabled values when these values are read-only" do
      section_test = IssueTemplate.find(3).section_groups[1].sections[0]
      section_test.empty_value = "value1;value3"
      section_test.text = "value1;value2;value3"
      section_test.placeholder = "value2;value3"
      section_test.save

      visit new_issue_path(project_id: project.identifier, template_id: 3)

      expect(page).to have_css("input[type='checkbox'][id='issue_issue_template_section_groups_attributes_2_0_sections_attributes_10_0']:disabled")
      expect(page).to_not have_css("input[type='checkbox'][id='issue_issue_template_section_groups_attributes_2_0_sections_attributes_10_1']:disabled")
      expect(page).to have_css("input[type='checkbox'][id='issue_issue_template_section_groups_attributes_2_0_sections_attributes_10_2']:disabled")

    end

    it "show generic button text (add/delete)" do
      visit new_issue_path(project_id: project.identifier, template_id: template_with_repeatable_sections.id)

      expect(page).to have_selector("a.add_sections_group", text: "Repeat this bloc")

      # Add repeatable section
      find("a.add_sections_group").click

      expect(page).to have_selector("a.destroy_sections_group", text: "Delete this bloc")
    end

    it "show personalized button text (add/delete)" do
      personalized_add_button_text = "Add section"
      personalized_delete_button_text = "Delete section"

      # Add personalized delete/add button text
      template_section_group = IssueTemplateSectionGroup.find_by(issue_template_id: template_with_repeatable_sections.id)
      template_section_group.add_button_title = personalized_add_button_text
      template_section_group.delete_button_title = personalized_delete_button_text
      template_section_group.save

      visit new_issue_path(project_id: project.identifier, template_id: template_with_repeatable_sections.id)

      expect(page).to have_selector("a.add_sections_group", text: personalized_add_button_text)

      # Add repeatable section
      find("a.add_sections_group").click

      expect(page).to have_selector("a.destroy_sections_group", text: personalized_delete_button_text)
    end
  end

  describe "Numeric Field" do
    let (:group_id) { IssueTemplate.find(6).section_groups[0].id }
    let (:section) { IssueTemplate.find(6).section_groups[0].sections[8] }

    it "displays the expected numeric field on the 'New Issue' page with the default value" do
      visit new_issue_path(project_id: project.identifier, template_id: 6)
      expect(page).to have_css("input[name='issue[issue_template][section_groups_attributes][#{group_id}][0][sections_attributes][#{section.id}][empty_value]'][value='#{section.empty_value}']")
    end

    it "displays the expected numeric field on the 'New Issue' page with range display" do
      template = IssueTemplate.find(6)
      template.section_groups[0].sections[8].select_type = "1"
      template.save

      visit new_issue_path(project_id: project.identifier, template_id: 6)
      expect(page).to have_css("input[type='range'][min='#{section.min_value}'][max='#{section.max_value}'][value='#{section.empty_value}']")
    end

    it "keeps the value in issue description" do
      visit new_issue_path(project_id: project.identifier, template_id: 6)

      fill_in 'issue_issue_template_section_groups_attributes_5_0_sections_attributes_15_text', with: '01/01/2020'
      fill_in("issue[issue_template][section_groups_attributes][#{group_id}][0][sections_attributes][#{section.id}][empty_value]", with: "5")

      click_on 'Create'

      expect(page).to have_content('created', wait: true)

      expect(Issue.last.description).to include("#{section.title}")
      expect(Issue.last.description).to include("5")
    end

  end
  describe "hidden fields" do
    it "can hide file attachment part" do
      visit new_issue_path(project_id: project.identifier, template_id: template_4.id)
      expect(page).to have_field('Subject', with: 'test_create')
      expect(page).to_not have_selector('#attachments_form')
    end
  end

  describe "New issue using a template" do

    before do
      IssueTemplateProject.create(project_id: 1, issue_template_id: template_4.id)
    end

    it "does not display the field project when only one is available" do
      visit new_issue_path(project_id: 1, template_id: template_4.id)
      expect(page).to_not have_selector("#issue_project_id")
    end

    it "displays a list of project field with only projects activated for the current template" do
      # activate the template 4 on the project id=3
      IssueTemplateProject.create(project_id: 3, issue_template_id: template_4.id)
      visit new_issue_path(project_id: 1, template_id: template_4.id)

      expect(page).to have_selector("#issue_project_id")

      expect(find("#issue_project_id").all('option').count).to eq(2)
      expect(find("#issue_project_id").all('option').first.value).to eq("1")
      expect(find("#issue_project_id").all('option').last.value).to eq("3")
    end

    if Redmine::Plugin.installed?(:redmine_customize_core_fields)
      #(when both the option override_issue_form, project.module_enabled /customize_core_fields/ are activated)
      it "displays a projects field filled with projects filtered for the current template" do

        Setting["plugin_redmine_customize_core_fields"] = { "override_issue_form" => "true" }
        EnabledModule.create!(:project_id => 1, :name => "customize_core_fields")

        core_field = CoreField.create!(:identifier => "project_id", :position => 1, :visible => true)
        core_field.role_ids = [1, 2]
        core_field.save

        # activate the template 4 on the project id=3
        IssueTemplateProject.create(project_id: 3, issue_template_id: template_4.id)

        visit new_issue_path(project_id: 1, template_id: template_4.id)

        expect(page).to have_selector("#issue_project_id")

        expect(find("#issue_project_id").all('option').count).to eq(2)

      end
    end
  end

  describe "buttons icons" do

    let! (:group_id) { template_with_sections.section_groups[1].id }
    let! (:section_id) { template_with_sections.section_groups[1].sections[0].id }

    before do
      section_test = template_with_sections.section_groups[1].sections[0]
      section_test.update(
        text: "value1;value2;value3",
        icon_name: "person-fill;history",
        position: 1,
        placeholder: "value2", # default value
        select_type: "buttons_with_icons"
      )
    end

    it "displays expected button icons on the 'New Issue' page" do
      visit new_issue_path(project_id: project.identifier, template_id: 3)

      expect(page).to have_css("[id='issue[issue_template][section_groups_attributes][#{group_id}][0][sections_attributes][#{section_id}][text]']", text: "value1")
      expect(page).to have_css("[id='issue[issue_template][section_groups_attributes][#{group_id}][0][sections_attributes][#{section_id}][text]']", text: "value2", class: "selected-button-icon")
      expect(page).to have_css("[id='issue[issue_template][section_groups_attributes][#{group_id}][0][sections_attributes][#{section_id}][text]']", text: "value3")
      expect(page).to have_css(".octicon-person-fill")
      expect(page).to have_css(".octicon-history")
    end

    it "keeps the selected value in issue description" do
      visit new_issue_path(project_id: project.identifier, template_id: 3)

      fill_in 'issue_issue_template_section_groups_attributes_1_0_sections_attributes_7_text', with: 'One-line edited content'
      fill_in 'issue_issue_template_section_groups_attributes_1_0_sections_attributes_8_text', with: Date.parse('2020-01-01')

      div_element = find("[id='issue[issue_template][section_groups_attributes][#{group_id}][0][sections_attributes][#{section_id}][text]']", text: "value2")
      div_element.click

      click_on 'Create'

      expect(page).to have_content('created', wait: true)

      expect(Issue.last.description).to include("value2")
    end

  end

  describe "Field used issue template" do
    if Redmine::Plugin.installed?(:redmine_scn)
      it "displays the field issue-template when the user is an instance manager" do
        user = User.find(2)
        user.instance_manager = true
        user.save
        visit "issues/1"

        expect(page).to have_selector("div", text: "Issue template:")
      end
    end

    it "displays the field issue-template when the user is an admin" do
      user = User.find(2)
      user.admin = true
      user.save
      visit "issues/1"

      expect(page).to have_selector("div", text: "Issue template:")
    end

    it "does not display the field issue-template when the user is neither an admin nor a manager" do
      visit "issues/1"
      expect(page).not_to have_selector("div", text: "Issue template:")
    end
  end
end
