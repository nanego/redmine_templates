# frozen_string_literal: true

require "spec_helper"
require "active_support/testing/assertions"

describe IssueTemplatesController, type: :controller do
  include ActiveSupport::Testing::Assertions

  render_views

  fixtures :issue_templates, :projects, :users, :issue_statuses, :trackers, :enumerations,
           :roles, :members, :member_roles, :issue_template_section_groups, :issue_template_sections, :issue_template_projects

  let!(:template) { IssueTemplate.find(1) }
  let!(:role) { Role.find(1) }
  let!(:template_with_instruction) { IssueTemplate.find(5) }

  before do
    @request.session[:user_id] = 2
    role.add_permission!(:create_issue_templates)
  end

  context "POST init" do
    it "should fail without project id" do
      post :init
      assert_response 404
    end

    it "should succeed with project id" do
      post :init, params: { :project_id => 1 }
      expect(response).to be_successful
      assert_template 'new'
    end

    it "forbids to init new template if user has no permission" do
      role.remove_permission!(:create_issue_templates)
      post :init, params: { :project_id => 1 }
      expect(response).to have_http_status(:forbidden)
    end
  end

  context "GET new" do
    it "forbids to create new template if user has no permission" do
      role.remove_permission!(:create_issue_templates)
      get :new
      expect(response).to have_http_status(:forbidden)
    end

    it "should build section for the template" do
      get :new
      expect(response).to be_successful
      assert_template "new"
      expect(assigns(:issue_template).section_groups).to_not be_nil
    end
  end

  context "GET edit" do
    it "forbids issue modification if user has no permission" do
      role.remove_permission!(:create_issue_templates)
      get :edit, params: { id: template.id }
      expect(response).to have_http_status(:forbidden)
    end

    it "should succeed with an id" do
      get :edit, params: { id: IssueTemplate.first.id }
      expect(response).to be_successful
      assert_template 'edit'
      expect(assigns(:issue_template).section_groups).to_not be_nil
    end
  end

  context "GET copy" do

    let!(:template_origin) { IssueTemplate.find(3) }

    it "forbids issue copy if user has no permission" do
      role.remove_permission!(:create_issue_templates)
      get :copy, params: { id: template.id }
      expect(response).to have_http_status(:forbidden)
    end

    it "duplicates all attributes of the original template" do
      get :copy, params: { id: template_origin.id }
      expect(response).to be_successful

      assert_template 'new'

      expect(assigns(:issue_template).template_title).to eq "Copy of #{template_origin.template_title}"
      expect(assigns(:issue_template).subject).to eq template_origin.subject
      expect(assigns(:issue_template).priority).to eq template_origin.priority
      expect(assigns(:issue_template).status).to eq template_origin.status
      expect(assigns(:issue_template).tracker).to eq template_origin.tracker
    end

    it "duplicates all section groups of the original template" do
      get :copy, params: { id: template_origin.id }

      expect(assigns(:issue_template).section_groups.size).to eq(template_origin.section_groups.count)

      template_origin.section_groups.each_with_index do |group, ind|
        expect(assigns(:issue_template).section_groups[ind].title).to eq(template_origin.section_groups[ind].title)
        expect(assigns(:issue_template).section_groups[ind].id).to be_nil # Because it's a new instance as a copy
      end
    end

    it "duplicates all projects of the original template" do

      template_origin.secondary_projects = [Project.find(3), Project.find(4)] if Redmine::Plugin.installed?(:redmine_multiprojects_issue)
      template_origin.save

      get :copy, params: { id: template_origin.id }

      expect(assigns(:issue_template).assignable_projects.size).to eq(template_origin.template_projects.count)
      template_origin.template_projects.each_with_index do |group, ind|
        expect(assigns(:issue_template).assignable_projects[ind]).to eq(template_origin.template_projects[ind])
      end

      if Redmine::Plugin.installed?(:redmine_multiprojects_issue)
        expect(assigns(:issue_template).assignable_secondary_projects.size).to eq(template_origin.secondary_projects.count)
        template_origin.secondary_projects.each_with_index do |group, ind|
          expect(assigns(:issue_template).assignable_secondary_projects[ind]).to eq(template_origin.secondary_projects[ind])
        end
      end
    end

    it "duplicates all custom_field_values of the original template" do
      template_origin = IssueTemplate.find(3)
      field_attributes = { :field_format => 'string', :is_for_all => true, :is_filter => true, :trackers => Tracker.all }

      IssueCustomField.create!(field_attributes.merge(:name => 'Field 1', :visible => true))
      IssueCustomField.create!(field_attributes.merge(:name => 'Field 2', :visible => false, :role_ids => [1, 2]))
      IssueCustomField.create!(field_attributes.merge(:name => 'Field 3', :visible => false, :role_ids => [1, 3]))

      3.times do |i|
        template_origin.custom_field_values = { i + 1 => "Value for field #{i + 1}" }
      end
      template_origin.save

      get :copy, params: { id: template_origin.id }

      assigns(:issue_template).custom_field_values.each_with_index do |field, ind|
        expect(field.value).to eq("Value for field #{ind + 1}")
      end
    end
  end

  context "PUT update" do
    it "forbids issue modification if user has no permission" do
      role.remove_permission!(:create_issue_templates)

      expect {
        put :update, params: { :id => template.id, issue_template: { subject: "Modified subject", "template_project_ids" => template.template_projects.map(&:id) } }
      }.to_not change { template.subject }

      expect(response).to have_http_status(:forbidden)
    end

    it "should succeed and update the first template" do
      post :create, params: { :issue_template => { subject: "New issue", project_id: 1, tracker_id: 1, status_id: 1, template_title: "New template", template_project_ids: [1] } }
      template = IssueTemplate.last
      assert_no_difference('IssueTemplate.count') do
        put :update, params: { :id => template.id, issue_template: { subject: "Modified subject", template_project_ids: [1] } }
      end
      expect(response).to redirect_to edit_issue_template_path(template)
      template.reload
      assert_match /updated/, flash[:notice]
      expect(template.subject).to eq "Modified subject"
    end

    it "should successfully update sections positions" do
      expect(template_with_instruction.sections.size).to eq 2
      expect(template_with_instruction.sections.first.text).to eq "Text of an instruction field"
      expect(template_with_instruction.sections.first.position).to eq 1
      expect(template_with_instruction.sections.second.text).to eq ""
      expect(template_with_instruction.sections.second.position).to eq 2

      first_section_group = template_with_instruction.section_groups.first

      assert_difference('IssueTemplateSection.count', 1) do

        patch :update, params: {
          id: template_with_instruction.id,
          "issue_template" => {
            "template_title" => "New template with instructions",
            "id" => "5",
            "template_project_ids" => template_with_instruction.template_projects.map(&:id),
            section_groups_attributes: [
              { "position" => "1",
                "title" => "",
                "repeatable" => "0",
                id: first_section_group.id,
                sections_attributes: [
                  { "position" => "1",
                    "type" => "IssueTemplateSectionInstruction",
                    "instruction_type" => "note",
                    "text" => "Text of an instruction field",
                    "id" => "6" },
                  { "position" => "2",
                    "type" => "IssueTemplateSectionTextArea",
                    "title" => "Section title",
                    "description" => "Section description",
                    "text" => "",
                    "placeholder" => "",
                    "empty_value" => "No data",
                    "required" => "1",
                    "show_toolbar" => "0",
                    "id" => "5" },
                  { "position" => "3",
                    "type" => "IssueTemplateSectionInstruction",
                    "instruction_type" => "warning",
                    "text" => "New warning!" }
                ]
              }
            ]
          }
        }
      end

      expect(response).to redirect_to edit_issue_template_path(template_with_instruction)
      template_with_instruction.reload
      assert_match /updated/, flash[:notice]
      expect(template_with_instruction.sections.size).to eq 3
      expect(template_with_instruction.sections.first.text).to eq "Text of an instruction field"
      expect(template_with_instruction.sections.first.position).to eq 1
      expect(template_with_instruction.sections.third.text).to eq "New warning!"
      expect(template_with_instruction.sections.third.position).to eq 3
    end

    it "should successfully select (option show in the generated issue)" do
      expect do
        post :create, params: {
          :issue_template => {
            :template_title => "New template",
            :template_enabled => "1",
            :template_project_ids => ["1"],
            :tracker_id => 1,
            :status_id => 1,
            section_groups_attributes: [
              { "position" => "1",
                "title" => "",
                "repeatable" => "0",
                sections_attributes: [
                  { "position" => "1",
                    "type" => "IssueTemplateSectionInstruction",
                    "instruction_type" => "info",
                    "text" => "New instruction",
                    "display_mode" => "1",
                  },
                ]
              }
            ]
          }
        }
      end.to change { IssueTemplate.count }.by(1)
      expect(IssueTemplate.last.section_groups.first.sections.first.display_mode).to eq("1")
    end

    it "creates issue template section with button icons and sets default icon if not provided" do
      expect do
        post :create, params: {
          :issue_template => {
            :template_title => "New template",
            :template_enabled => "1",
            :template_project_ids => ["1"],
            :tracker_id => 1,
            :status_id => 1,
            section_groups_attributes: [
              { "position" => "1",
                "title" => "",
                "repeatable" => "0",
                sections_attributes: [
                  { "position" => "1",
                    "type" => "IssueTemplateSectionSelect",
                    "select_type" => "buttons_with_icons",
                    "text" => "value1;value2",
                    "title" => "section buttons icons",
                    "icon_name" => "history;",
                  },
                ]
              }
            ]
          }
        }
      end.to change { IssueTemplate.count }.by(1)

      expect(IssueTemplate.last.section_groups.first.sections.first.text).to eq("value1;value2")
      expect(IssueTemplate.last.section_groups.first.sections.first.icon_name).to eq("history;alert-fill")
    end

    it "Should successfully creates issue template section with range" do
      expect do
        post :create, params: {
          :issue_template => {
            :template_title => "New template",
            :template_enabled => "1",
            :template_project_ids => ["1"],
            :tracker_id => 1,
            :status_id => 1,
            section_groups_attributes: [
              { "position" => "1",
                "title" => "test",
                "repeatable" => "0",
                sections_attributes: [
                  { "position" => "1",
                    "title" => "test range",
                    "type" => "IssueTemplateSectionNumeric",
                    "placeholder" => 2,# min
                    "text" => 4,#max
                    "empty_value" => 50,
                    "required" => false #display_in_range
                  },
                ]
              }
            ]
          }
        }
      end.to change { IssueTemplate.count }.by(1)

      new_template = IssueTemplate.last.section_groups.first.sections.first
      expect(new_template.placeholder).to eq("2")
      expect(new_template.text).to eq("4")
      expect(new_template.empty_value).to eq("50")
      expect(new_template.required).to eq(false)
    end

    it "Should not accept a default value longer than the maximum specified length" do
      expect do
        post :create, params: {
          :issue_template => {
            :template_title => "New template",
            :template_enabled => "1",
            :template_project_ids => ["1"],
            :tracker_id => 1,
            :status_id => 1,
            section_groups_attributes: [
              { "position" => "1",
                "title" => "test",
                "repeatable" => "0",
                sections_attributes: [
                  { "position" => "1",
                    "title" => "test range",
                    "type" => "IssueTemplateSectionNumeric",
                    "placeholder" => 1,# min
                    "text" => 2,#max
                    "empty_value" => 500,
                    "required" => false #display_in_range
                  },
                ]
              }
            ]
          }
        }
      end.to change { IssueTemplate.count }.by(0)
    end

    it "Should not accept a default value shorter than the minimum specified length" do
      expect do
        post :create, params: {
          :issue_template => {
            :template_title => "New template",
            :template_enabled => "1",
            :template_project_ids => ["1"],
            :tracker_id => 1,
            :status_id => 1,
            section_groups_attributes: [
              { "position" => "1",
                "title" => "test",
                "repeatable" => "0",
                sections_attributes: [
                  { "position" => "1",
                    "title" => "test range",
                    "type" => "IssueTemplateSectionNumeric",
                    "placeholder" => 2,# min
                    "text" => 4,# max
                    "empty_value" => 5,
                    "required" => false #display_in_range
                  },
                ]
              }
            ]
          }
        }
      end.to change { IssueTemplate.count }.by(0)
    end
  end

  describe "issue creation" do
    it "forbids to init a new template if user has no permission" do
      role.remove_permission!(:create_issue_templates)

      post :init, params: { :project_id => '1', :tracker_id => '1' }

      expect(response).to have_http_status(:forbidden)
    end

    it "forbids to create a new template if user has no permission" do
      role.remove_permission!(:create_issue_templates)

      expect {
        post :create, params: { :issue_template => { subject: "New issue", project_id: 1, tracker_id: 1, status_id: 1, template_title: "New template", template_project_ids: [1] } }
      }.to_not change(IssueTemplate, :count)

      expect(response).to have_http_status(:forbidden)
    end

    it "should succeed and assign a new template" do
      post :create, params: { :issue_template => { subject: "New issue", project_id: 1, tracker_id: 1, status_id: 1, template_title: "New template", template_project_ids: [1] } }
      new_template = IssueTemplate.last
      expect(response).to redirect_to(edit_issue_template_path(new_template))
      expect(flash[:notice]).to eq "New issue template successfully created!"
      expect(new_template.try(:subject)).to eq "New issue"
    end

    it "should add issue template through the init new template screen" do
      post :init, params: { :project_id => '1', :tracker_id => '1' }
      expect(response).to be_successful
      assert_template 'new'

      post :create, params: { :issue_template => { :tracker_id => '1',
                                                   :start_date => "2006-12-26",
                                                   :priority_id => "4",
                                                   :subject => "new test template subject",
                                                   :description => "new template description",
                                                   :done_ratio => "0",
                                                   :due_date => "",
                                                   :assigned_to_id => "",
                                                   :template_title => "Init new template",
                                                   :template_enabled => true,
                                                   :project_id => '1',
                                                   :template_project_ids => ['1'],
                                                   :status_id => '1' } }

      # find created template
      template = IssueTemplate.find_by_template_title("Init new template")
      assert_kind_of IssueTemplate, template

      # check redirection
      expect(response).to redirect_to(:controller => 'issue_templates', :action => 'edit', :id => template.id)
    end
  end

  it "should show Number of projects in templates/index" do
    get :index
    template = IssueTemplate.find(2)
    expect(response.body).to have_css(".template_projects")
    expect(response.body).to have_css("tr[data-template-id=#{template.id}] td[class='template_column_count']")
    expect(response.body).to have_css("tr[data-template-id=#{template.id}] td:nth-child(6)", text: "#{template.issue_template_projects.size}", exact_text: true)
  end
end
