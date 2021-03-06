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

RSpec.describe "creating issues with templates", type: :system do
  include ActiveSupport::Testing::Assertions

  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
           :trackers, :projects_trackers, :enabled_modules, :issue_statuses, :issues,
           :enumerations, :custom_fields, :custom_values, :custom_fields_trackers,
           :watchers, :journals, :journal_details, :versions,
           :workflows, :issue_templates, :issue_template_projects, :issue_template_descriptions

  let(:template_with_sections) { IssueTemplate.find(3) }
  let(:project) { Project.find(2) }

  before do
    log_user('jsmith', 'jsmith')
  end

  describe "templates with sections and instructions" do
    it "shows an issue form with sections fields instead of description field" do
      visit new_issue_path(project_id: project.identifier, template_id: template_with_sections.id)

      expect(page).to have_field('Subject', with: 'Issue created with template 3')
      expect(page).to_not have_selector("description")
      expect(page).to have_selector('#issue_issue_template_descriptions_attributes_0_text', text: "Type here first section content")
      expect(page).to have_selector('#issue_issue_template_descriptions_attributes_2_text') #, text: "Default content"

      fill_in 'issue_issue_template_descriptions_attributes_2_text', with: 'One-line edited content'
      fill_in 'issue_issue_template_descriptions_attributes_3_text', with: '01/01/2020'
      click_on 'Create'

      expect(page).to have_selector('.description', text: "Type here first section content")
      expect(page).to have_selector('.description', text: "Type here second section content")
      expect(page).to have_selector('.description', text: 'One-line edited content')
    end
  end

end
