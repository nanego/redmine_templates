require "spec_helper"
require "active_support/testing/assertions"

RSpec.describe "issue_template view", type: :system do
  include ActiveSupport::Testing::Assertions
  include IssuesHelper

  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
           :trackers, :projects_trackers, :enabled_modules, :issue_statuses, :issues,
           :enumerations, :custom_fields, :custom_values, :custom_fields_trackers,
           :workflows, :issue_templates, :issue_template_projects, :issue_template_section_groups, :issue_template_sections

  let!(:template_with_sections) { IssueTemplate.find(3) }
  let!(:template_4) { IssueTemplate.find(4) }
  let!(:project) { Project.find(2) }

  context "logged as admin" do

    describe "Display all custom fields used in issue_template view" do

      before do
        log_user('admin', 'admin')
      end

      it "displays all project's custom-fields when selecting a project" do
        custom_field = CustomField.create(name: "CustomField_project2", field_format: "string", visible: "1", type: "IssueCustomField", projects: [project])

        visit new_issue_template_path

        expect(page).to_not have_selector("label", text: custom_field.name)

        find("#link_update_project_list").click

        within '#ajax-modal' do
          page.find("label", :text => project.name).click
          page.find("#button_apply_projects").click
        end
        expect(page).to_not have_selector('#ajax-modal', wait: 2)

        project.all_issue_custom_fields.each do |field|
          expect(page).to have_selector("label", text: field.name)
        end

        expect(page).to have_selector("label", text: custom_field.name)
      end

      it "displays all tracker's custom-field when selecting a tracker" do
        tracker_1 = Tracker.find(1)
        tracker_2 = Tracker.find(2)
        custom_field_1 = CustomField.create(name: "CustomField_tracker1", field_format: "string", visible: "1", type: "IssueCustomField", trackers: [tracker_1])
        custom_field_2 = CustomField.create(name: "CustomField_tracker2", field_format: "string", visible: "1", type: "IssueCustomField", trackers: [tracker_2])

        visit new_issue_template_path

        tracker_1.custom_fields.all.each do |field|
          expect(page).to have_selector("label", text: field.name)
        end
        expect(page).to_not have_selector("label", text: custom_field_2.name)

        select "Feature request", :from => "issue_template_tracker_id"

        tracker_2.custom_fields.all.each do |field|
          expect(page).to have_selector("label", text: field.name)
        end
        expect(page).to_not have_selector("label", text: custom_field_1.name)
      end

    end

  end

  context "logged as non-admin user" do

    before do
      log_out

      # Add permission to user
      user_jsmith = User.find(2)
      role = Member.where(user: user_jsmith, project: project).first.roles.first
      role.add_permission!(:create_issue_templates)
      role.add_permission!(:manage_project_issue_templates)

      log_user('jsmith', 'jsmith')
    end

    describe "Template edition by a non-admin" do

      it "should be accessible by a non-admin user with permissions" do
        visit new_issue_template_path
        expect(page).to have_current_path('/issue_templates/new', wait: true)

        find("#link_update_project_list").click

        expect(page).to have_selector('#ajax-modal', wait: true)

        within '#ajax-modal' do
          page.find("label", :text => project.name).click
          page.find("#button_apply_projects").click
        end
      end
    end
  end

end
