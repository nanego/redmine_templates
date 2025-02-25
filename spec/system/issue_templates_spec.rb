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
  expect(page).to have_current_path('/my/page', wait: true)
end

RSpec.describe "creating issues with templates", type: :system do
  include ActiveSupport::Testing::Assertions
  include IssuesHelper

  fixtures :projects, :users, :issues,
           :issue_templates, :issue_template_projects, :issue_template_section_groups, :issue_template_sections

  let(:template_with_sections) { IssueTemplate.find(3) }
  let(:template_with_repeatable_sections) {IssueTemplate.find(6)}

  before do
    log_user('admin', 'admin')
  end

  describe "test read only values in the list of values of section template" do
    it "Save the read only values in the column empty_data of the table issue_template_sections" do
      visit edit_issue_template_path(1)

      expect(page).to have_selector('#issue_template_split_description')

      find("#issue_template_split_description").click
      find(".icon-add").click
      find(".icon-list").click
      find_by_id("new_section").find("option[value='7']").click #['Nouvelle liste de valeurs', 7]

      # add section group
      find('button[data-action="split-description#addSection"]').click
      # click on Show the details
      all('a[data-action="description-item-form#expand_collapse"]')[1].click
      # select list of values
      fill_in 'issue_template_section_groups_attributes__id_group_section__sections_attributes_0_title', with: 'list test'

      array_values = ['val_1', 'val_2', 'val_3']
      # **** add the first value  ****
      find(".add_possible_value").click

      # fill the informations
      find("#checked").click
      fill_in "value", with: 'val_1'
      find("#read_only").click

      # **** add the second value  ****
      find(".add_possible_value").click
      all('#checked')[1].click
      all("#value")[1].fill_in with: 'val_2'

      # **** add the third value  ****
      find(".add_possible_value").click
      all('#value')[2].fill_in with: 'val_3'
      all('#read_only')[2].click

      # save the template
      find('input[type=submit]').click
      expect(page).to have_content('template has been updated')

      section_test = IssueTemplate.find(1).section_groups[0].sections[0]
      expect(section_test.empty_value).to eq("#{array_values[0]};#{array_values[2]}")
      expect(section_test.placeholder).to eq("#{array_values[0]};#{array_values[1]}")

    end
  end

  describe "Fail validation of template" do
    it "Should keep the selected projects" do
      visit new_issue_template_path
      # open selected projects modal
      find('#link_update_project_list').click

      expect(page).to have_selector('#ajax-modal', wait: true)

      within '#ajax-modal' do
        # select projects with id  3 , 5
        find("input[value='5']").click
        find("input[value='3']").click
        find("input[id='button_apply_projects']").click
      end

      # Make fail validation
      find("input[name='commit']").click

      # selected projects 3, project_id=3 +project_id= 5 + its child project_id=6
      expect(page).to have_selector("span", text: "#{Project.find(3).name}")
      expect(page).to have_selector("span", text: "#{Project.find(5).name}")
      expect(page).to have_selector("span", text: "#{Project.find(6).name}")

      # Remake succes validation
      fill_in 'issue_template_template_title', with: 'test'
      
      find("input[name='commit']").click

      # wait for the methode similar_templates (in ajax)
      sleep(5)
      expect(IssueTemplate.last.template_projects.count).to eq(3)
    end
  end

  describe "Template with sections" do 
    it "it display personalized button title field (add/delete)" do
      personalized_add_button_text = "Add section"
      personalized_delete_button_text = "Delete section"

      # Add personalized delete/add button text
      template_section_group = IssueTemplateSectionGroup.find_by(issue_template_id: template_with_repeatable_sections.id)
      template_section_group.add_button_title = personalized_add_button_text
      template_section_group.delete_button_title = personalized_delete_button_text
      template_section_group.save

      visit edit_issue_template_path(template_with_repeatable_sections.id)

      # Display add/delete button text prefilled fields
      expect(page).to have_selector("input[value='"+ personalized_add_button_text +"']")
      expect(page).to have_selector("input[value='"+ personalized_delete_button_text +"']")
    end

    it "it do not display personalized button title field (add/delete)" do
      visit edit_issue_template_path(template_with_sections.id)

      # Do not display add/delete button text fields 
      expect(page).not_to have_selector("input[name='issue_template[section_groups_attributes][0][add_button_title]']")
      expect(page).not_to have_selector("input[name='issue_template[section_groups_attributes][0][delete_button_title]']")
      
    end

    it "it display personalized button title field (add/delete) on click" do
      visit edit_issue_template_path(1)

      # Do not display add/delete button text fields
      expect(page).not_to have_selector("input[name='issue_template[section_groups_attributes][0][add_button_title]']")
      expect(page).not_to have_selector("input[name='issue_template[section_groups_attributes][0][delete_button_title]']")

      expect(page).to have_selector('#issue_template_split_description')

      find("#issue_template_split_description").click
      find(".icon-add").click
      find(".icon-list").click
      find("#issue_template_section_groups_attributes_0_repeatable").click

      # Display add/delete button text prefilled fields
      expect(page).to have_selector("input[name='issue_template[section_groups_attributes][0][add_button_title]']")
      expect(page).to have_selector("input[name='issue_template[section_groups_attributes][0][delete_button_title]']")   
    end
  end
end
