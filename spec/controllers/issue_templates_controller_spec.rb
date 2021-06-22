require "spec_helper"
require "active_support/testing/assertions"

describe IssueTemplatesController, type: :controller do
  include ActiveSupport::Testing::Assertions

  render_views

  fixtures :issue_templates, :projects, :users, :issue_statuses, :trackers, :enumerations,
           :roles, :members, :member_roles, :issue_template_descriptions, :issue_template_projects

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
      post :init, params: {:project_id => 1}
      expect(response).to be_successful
      assert_template 'new'
    end

    it "forbids to init new template if user has no permission" do
      role.remove_permission!(:create_issue_templates)
      post :init, params: {:project_id => 1}
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
      expect(assigns(:issue_template).descriptions).to_not be_nil
    end
  end

  context "GET edit" do
    it "forbids issue modification if user has no permission" do
      role.remove_permission!(:create_issue_templates)
      get :edit, params: {id: template.id}
      expect(response).to have_http_status(:forbidden)
    end

    it "should succeed with an id" do
      get :edit, params: {id: IssueTemplate.first.id}
      expect(response).to be_successful
      assert_template 'edit'
      expect(assigns(:issue_template).descriptions).to_not be_nil
    end
  end

  context "PUT update" do
    it "forbids issue modification if user has no permission" do
      role.remove_permission!(:create_issue_templates)

      expect {
        put :update, params: {:id => template.id, issue_template: {subject: "Modified subject"}}
      }.to_not change { template.subject }

      expect(response).to have_http_status(:forbidden)
    end

    it "should succeed and update the first template" do
      post :create, params: {:issue_template => {subject: "New issue", project_id: 1, tracker_id: 1, status_id: 1, template_title: "New template", template_project_ids: [1]}}
      template = IssueTemplate.last
      assert_no_difference('IssueTemplate.count') do
        put :update, params: {:id => template.id, issue_template: {subject: "Modified subject"}}
      end
      expect(response).to redirect_to edit_issue_template_path(template)
      template.reload
      assert_match /updated/, flash[:notice]
      expect(template.subject).to eq "Modified subject"
    end

    it "should successfully update descriptions positions" do
      instruction = IssueTemplateDescriptionInstruction.new(:text => "Text of an instruction field",
                                                            :type => "IssueTemplateDescriptionInstruction",
                                                            :instruction_type => "note",
                                                            :position => 1)
      template_with_instruction.descriptions = [instruction]
      template_with_instruction.save

      expect(template_with_instruction.descriptions.size).to eq 1
      expect(template_with_instruction.descriptions.first.text).to eq "Text of an instruction field"
      expect(template_with_instruction.descriptions.first.position).to eq 1

      assert_difference('IssueTemplateDescription.count', 1) do
        put :update, params: {
            :id => template_with_instruction.id,
            issue_template: {
                descriptions_attributes: {
                    "0" => {
                        :id => template_with_instruction.descriptions.first.id,
                        :text => template_with_instruction.descriptions.first.text,
                        :type => template_with_instruction.descriptions.first.type,
                        :position => 2,
                    },
                    "1" => {
                        :text => "Text of an other instruction field 2",
                        :type => "IssueTemplateDescriptionInstruction",
                        :instruction_type => 'warning',
                        :position => 1,
                    }
                }
            }
        }
      end

      expect(response).to redirect_to edit_issue_template_path(template_with_instruction)
      template_with_instruction.reload
      assert_match /updated/, flash[:notice]
      expect(template_with_instruction.descriptions.first.text).to eq "Text of an other instruction field 2"
      expect(template_with_instruction.descriptions.first.position).to eq 1
      expect(template_with_instruction.descriptions.second.text).to eq "Text of an instruction field"
      expect(template_with_instruction.descriptions.second.position).to eq 2
    end
  end

  describe "issue creation" do
    it "forbids to init a new template if user has no permission" do
      role.remove_permission!(:create_issue_templates)

      post :init, params: {:project_id => '1', :tracker_id => '1'}

      expect(response).to have_http_status(:forbidden)
    end

    it "forbids to create a new template if user has no permission" do
      role.remove_permission!(:create_issue_templates)

      expect {
        post :create, params: {:issue_template => {subject: "New issue", project_id: 1, tracker_id: 1, status_id: 1, template_title: "New template", template_project_ids: [1]}}
      }.to_not change(IssueTemplate, :count)

      expect(response).to have_http_status(:forbidden)
    end

    it "should succeed and assign a new template" do
      post :create, params: {:issue_template => {subject: "New issue", project_id: 1, tracker_id: 1, status_id: 1, template_title: "New template", template_project_ids: [1]}}
      new_template = IssueTemplate.last
      expect(response).to redirect_to(edit_issue_template_path(new_template))
      expect(flash[:notice]).to eq "New issue template successfully created!"
      expect(new_template.try(:subject)).to eq "New issue"
    end

    it "should add issue template through the init new template screen" do
      post :init, params: {:project_id => '1', :tracker_id => '1'}
      expect(response).to be_successful
      assert_template 'new'

      post :create, params: {:issue_template => {:tracker_id => '1',
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
                                                 :status_id => '1'}}

      # find created template
      template = IssueTemplate.find_by_template_title("Init new template")
      assert_kind_of IssueTemplate, template

      # check redirection
      expect(response).to redirect_to(:controller => 'issue_templates', :action => 'edit', :id => template.id)
    end
  end

end
