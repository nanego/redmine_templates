# frozen_string_literal: true

require "spec_helper"

describe "Issue creation with templates", type: :request do

  fixtures :projects, :users, :email_addresses, :roles, :members, :member_roles,
           :trackers, :projects_trackers, :enabled_modules, :issue_statuses, :issues,
           :enumerations, :custom_fields, :custom_values, :custom_fields_trackers,
           :workflows, :issue_templates, :issue_template_projects,
           :issue_template_section_groups, :issue_template_sections

  let(:template_with_sections) { IssueTemplate.find(3) }
  let(:template_4) { IssueTemplate.find(4) }
  let(:template_with_repeatable_sections) { IssueTemplate.find(6) }
  let(:project) { Project.find(2) }
  let(:user_jsmith) { User.find(2) }

  before do
    User.current = user_jsmith
    post '/login', params: { username: 'jsmith', password: 'jsmith' }
  end

  describe "POST /projects/:project_id/issues with template sections" do
    it "creates issue with sections and concatenates them into description" do
      expect {
        post project_issues_path(project),
             params: {
               issue: {
                 tracker_id: 3,
                 status_id: 2,
                 subject: 'Issue with sections',
                 priority_id: 5,
                 issue_template_id: template_with_sections.id,
                 issue_template: {
                   section_groups_attributes: {
                     "1" => {
                       "0" => {
                         sections_attributes: {
                           "1" => { text: "First section content" },
                           "2" => { text: "Second section content" }
                         }
                       }
                     }
                   }
                 }
               }
             }
      }.to change { Issue.count }.by(1)

      issue = Issue.last
      expect(issue.description).to include("First section content")
      expect(issue.description).to include("Second section content")
    end

    it "uses empty_value when section text is empty" do
      expect {
        post project_issues_path(project),
             params: {
               issue: {
                 tracker_id: 3,
                 status_id: 2,
                 subject: 'Issue with empty section',
                 priority_id: 5,
                 issue_template_id: template_4.id,
                 issue_template: {
                   section_groups_attributes: {
                     "3" => {
                       "0" => {
                         sections_attributes: {
                           "3" => { text: "", empty_value: "Default value used" }
                         }
                       }
                     }
                   }
                 }
               }
             }
      }.to change { Issue.count }.by(1)

      issue = Issue.last
      expect(issue.description).to include("Default value used")
    end
  end

  describe "repeatable sections" do
    it "creates multiple instances of repeatable section groups" do
      expect {
        post project_issues_path(project),
             params: {
               issue: {
                 tracker_id: 3,
                 status_id: 2,
                 subject: 'Issue with repeatable sections',
                 priority_id: 5,
                 issue_template_id: template_with_repeatable_sections.id,
                 issue_template: {
                   section_groups_attributes: {
                     "5" => {
                       "0" => {
                         sections_attributes: {
                           "13" => { text: "First instance" }
                         }
                       },
                       "1" => {
                         sections_attributes: {
                           "13" => { text: "Second instance" }
                         }
                       }
                     }
                   }
                 }
               }
             }
      }.to change { Issue.count }.by(1)

      issue = Issue.last
      expect(issue.description).to include("First instance")
      expect(issue.description).to include("Second instance")
    end
  end

  describe "section with numeric field" do
    it "includes numeric field value in description" do
      template = template_with_repeatable_sections
      section = template.section_groups[0].sections[8]

      expect {
        post project_issues_path(project),
             params: {
               issue: {
                 tracker_id: 3,
                 status_id: 2,
                 subject: 'Issue with numeric field',
                 priority_id: 5,
                 issue_template_id: template.id,
                 issue_template: {
                   section_groups_attributes: {
                     "#{section.issue_template_section_group_id}" => {
                       "0" => {
                         sections_attributes: {
                           "#{section.id}" => { empty_value: "42" }
                         }
                       }
                     }
                   }
                 }
               }
             }
      }.to change { Issue.count }.by(1)

      issue = Issue.last
      expect(issue.description).to include("42")
    end
  end

  describe "template with hidden attachments" do
    it "does not show attachments form when configured" do
      template_4.update(hide_file_attachment: true)

      get new_project_issue_path(project, template_id: template_4.id)
      expect(response).to be_successful
      expect(response.body).to_not include('attachments_form')
    end
  end

  describe "project filtering for templates" do
    before do
      IssueTemplateProject.create(project_id: 1, issue_template_id: template_4.id)
    end

    it "shows only projects where template is enabled" do
      IssueTemplateProject.create(project_id: 3, issue_template_id: template_4.id)

      get new_project_issue_path(Project.find(1), template_id: template_4.id)
      expect(response).to be_successful

      doc = Nokogiri::HTML(response.body)
      project_options = doc.css('#issue_project_id option')
      project_ids = project_options.map { |opt| opt['value'].to_i }

      expect(project_ids).to include(1, 3)
      expect(project_ids).to_not include(2)
    end

    it "does not show project select when only one project is available" do
      get new_project_issue_path(Project.find(1), template_id: template_4.id)
      expect(response).to be_successful
      expect(response.body).to_not include('issue_project_id')
    end
  end

  describe "button icons section" do
    it "saves selected button icon value to description" do
      section = template_with_sections.section_groups[1].sections[0]
      section.update(
        text: "value1;value2;value3",
        icon_name: "person-fill;history;star",
        select_type: "buttons_with_icons",
        placeholder: "value2"
      )

      expect {
        post project_issues_path(project),
             params: {
               issue: {
                 tracker_id: 3,
                 status_id: 2,
                 subject: 'Issue with button icons',
                 priority_id: 5,
                 issue_template_id: template_with_sections.id,
                 issue_template: {
                   section_groups_attributes: {
                     "#{section.issue_template_section_group_id}" => {
                       "0" => {
                         sections_attributes: {
                           "#{section.id}" => { text: "value3" }
                         }
                       }
                     }
                   }
                 }
               }
             }
      }.to change { Issue.count }.by(1)

      issue = Issue.last
      expect(issue.description).to include("value3")
    end
  end

  describe "issue template field visibility" do
    it "shows issue_template field to admin users" do
      User.current = User.find(1)
      post '/login', params: { username: 'admin', password: 'admin' }

      get issue_path(Issue.find(1))
      expect(response).to be_successful
      expect(response.body).to include("Issue template")
    end

    it "does not show issue_template field to regular users" do
      get issue_path(Issue.find(1))
      expect(response).to be_successful
      expect(response.body).to_not include("Issue template:")
    end
  end
end
