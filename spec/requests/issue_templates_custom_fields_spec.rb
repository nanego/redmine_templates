# frozen_string_literal: true

require "spec_helper"

describe "IssueTemplate custom fields visibility", type: :request do

  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
           :trackers, :projects_trackers, :enabled_modules, :issue_statuses,
           :custom_fields, :custom_fields_trackers,
           :issue_templates, :issue_template_projects

  let(:project) { Project.find(2) }
  let(:tracker_1) { Tracker.find(1) }
  let(:tracker_2) { Tracker.find(2) }
  let(:admin) { User.find(1) }

  before do
    User.current = admin
    post '/login', params: { username: 'admin', password: 'admin' }
  end

  describe "GET /issue_templates/new" do
    it "successfully loads the form" do
      get new_issue_template_path
      expect(response).to be_successful
      expect(response.body).to include('issue_template')
    end

    it "respects custom field visibility by tracker" do
      # Create custom fields specific to each tracker
      custom_field_1 = CustomField.create!(
        name: "CustomField_tracker1",
        field_format: "string",
        visible: true,
        type: "IssueCustomField",
        trackers: [tracker_1]
      )
      custom_field_2 = CustomField.create!(
        name: "CustomField_tracker2",
        field_format: "string",
        visible: true,
        type: "IssueCustomField",
        trackers: [tracker_2]
      )

      # Test with template having tracker_1
      template = IssueTemplate.create!(
        template_title: "Test template",
        tracker_id: tracker_1.id,
        status_id: 1,
        author_id: admin.id,
        template_project_ids: [project.id]
      )

      get edit_issue_template_path(template)
      expect(response).to be_successful

      # Verify the form contains fields for the assigned tracker
      expect(response.body).to include(custom_field_1.name)
      expect(response.body).to_not include(custom_field_2.name)
    end
  end

  describe "permissions for non-admin users" do
    let(:user_jsmith) { User.find(2) }

    before do
      User.current = nil
      role = Member.where(user: user_jsmith, project: project).first.roles.first
      role.add_permission!(:create_issue_templates)
      role.add_permission!(:manage_project_issue_templates)
      User.current = user_jsmith
      post '/login', params: { username: 'jsmith', password: 'jsmith' }
    end

    it "allows non-admin user with permissions to access template creation" do
      get new_issue_template_path
      expect(response).to be_successful
      expect(response.body).to include('issue_template')
    end
  end
end
