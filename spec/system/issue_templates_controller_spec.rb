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

      it "displays deactivated projects in the correct order" do
        template_test = IssueTemplate.find(2)
        project_test = Project.find(5)
        project_test.status = Project::STATUS_ARCHIVED
        project_test.save
        template_test.template_project_ids = Project.all.map(&:id)
        project_parent = project_test.parent.name
        expect(IssueTemplate.find(2).template_projects.count).to eq(6)

        visit '/issue_templates/2/edit'

        find("#link_update_project_list").click

        within '#ajax-modal' do
          label_parent = find(:xpath, "//label[text()=' #{project_parent}']")
          labels = all('label')
          filtered_labels = labels.reject { |label| label == label_parent }
          closest_label = find_closest_label(filtered_labels, label_parent)

          expect(closest_label.text).to eq(project_test.name)
        end
      end

      def find_closest_label(labels, target_element)
        closest_label = labels.min_by do |label|
          label_distance = (target_element['offsetTop'].to_i - label['offsetTop'].to_i).abs +
            (target_element['offsetLeft'].to_i - label['offsetLeft'].to_i).abs
        end

        return closest_label
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

    describe "Templates index" do
      it "displays templates that lack a tracker" do
        # Removing a tracker to simulate the absence of a tracker
        tracker_to_remove = Tracker.find(3)
        tracker_to_remove.destroy

        # Retrieving the issue template without a tracker
        template_without_tracker = IssueTemplate.find(6)

        # Verifying that the issue template has a tracker_id equal to 0
        expect(template_without_tracker.tracker_id).to eq(0)

        visit "/issue_templates"
        expect(page.body).to have_selector("a", text: "#{template_without_tracker.template_title}")
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
