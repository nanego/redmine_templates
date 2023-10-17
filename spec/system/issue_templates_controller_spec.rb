require "spec_helper"
require "active_support/testing/assertions"

def log_user(login, password)
  visit '/my/page'
  expect(current_path).to eq '/login'

  if Redmine::Plugin.installed?(:redmine_scn)
    click_on("ou s'authentifier par login / mot de passe")
  end

  within('#login-form form') do
    fill_in 'username', with: login
    fill_in 'password', with: password
    find('input[name=login]').click
  end
  expect(current_path).to eq '/my/page'
end

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

    it "Should not trigger the SQL update + callbacks without save call" do
      visit '/issue_templates/2/edit'

      expect(IssueTemplate.find(2).template_projects.count).to eq(1)
      find("#link_update_project_list").click

      within '#ajax-modal' do
        page.find("a", :text => 'All').click
        page.find("#button_apply_projects").click
      end

      expect(IssueTemplate.find(2).template_projects.count).to eq(1)
    end
  end

  describe "Template edition by a non-admin" do

    before do
      # Add permission to user
      user_jsmith = User.find(2)
      role = Member.where(user: user_jsmith, project: project).first.roles.first
      role.add_permission!(:create_issue_templates)
      role.add_permission!(:manage_project_issue_templates)
      log_user('jsmith', 'jsmith')
    end

    it "should be accessible by a non-admin user with permissions" do
      visit new_issue_template_path

      find("#link_update_project_list").click

      within '#ajax-modal' do
        page.find("label", :text => project.name).click
        page.find("#button_apply_projects").click
      end
    end
  end
end
