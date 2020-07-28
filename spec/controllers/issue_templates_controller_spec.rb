require "spec_helper"
require "active_support/testing/assertions"

describe IssueTemplatesController, type: :controller do
  include ActiveSupport::Testing::Assertions

  render_views

  fixtures :issue_templates, :projects, :users, :issue_statuses, :trackers, :enumerations

  before do
    @request.session[:user_id] = 1 #=> admin ; permissions are hard...
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
  end

  context "GET new" do
    it "should build section for the template" do
      get :new
      expect(response).to be_successful
      assert_template "new"
      expect(assigns(:issue_template).descriptions).to_not be_nil
    end
  end

  context "POST create" do
    it "should succeed and assign a new template" do
      post :create, params: {:issue_template => { subject: "New issue", project_id: 1, tracker_id: 1, status_id: 1, template_title: "New template", template_project_ids: [1] }}
      expect(response).to redirect_to(issue_templates_path(project: 'ecookbook'))
      expect(flash[:notice]).to eq "New issue template successfully created!"
      expect(IssueTemplate.last.try(:subject)).to eq "New issue"
    end
  end

  context "GET edit" do
    it "should succeed with an id" do
      get :edit, params: {id: IssueTemplate.first.id}
      expect(response).to be_successful
      assert_template 'edit'
      expect(assigns(:issue_template).descriptions).to_not be_nil
    end
  end

  context "PUT update" do
    it "should succeed and update the first template" do
      post :create, params: {:issue_template => { subject: "New issue", project_id: 1, tracker_id: 1, status_id: 1, template_title: "New template", template_project_ids: [1] }}
      template = IssueTemplate.last
      assert_no_difference('IssueTemplate.count') do
        put :update, params: {:id => template.id, issue_template: { subject: "Modified subject" }}
      end
      expect(response).to redirect_to(issue_templates_path(project: template.project.identifier))
      template.reload
      assert_match /updated/, flash[:notice]
      expect(template.subject).to eq "Modified subject"
      #assert_equal 1, template.project_id
      #assert_equal 2, template.tracker_id
      #assert_equal 6, template.priority_id
      #assert_equal 1, template.category_id
    end

    it "should successfuly update descriptions positions" do
      template = IssueTemplate.create(
        :project_id => 1,
        :tracker_id => 3,
        :status_id => 2,
        :author_id => 2,
        :subject => 'test_create',
        :template_title => 'New title template',
        :template_enabled => true,
        :template_project_ids => [1],
        :split_description => "1",
        :descriptions_attributes => [{
          :text => "Text of an instruction field",
          :type => "IssueTemplateDescriptionInstruction",
          :position => 1,
        }],
      )

      expect(template.descriptions.first.text).to eq "Text of an instruction field"
      expect(template.descriptions.first.position).to eq 1

      assert_difference('IssueTemplateDescription.count', 1) do
        put :update, params: {
            :id => template.id,
            issue_template: {
              descriptions_attributes: {
                "0" => {
                  :id => template.descriptions.first.id,
                  :position => 2,
                },
                "1" => {
                  :text => "Text of an instruction field 2",
                  :type => "IssueTemplateDescriptionInstruction",
                  :position => 1,
                }
              }
            }
          }
      end

      expect(response).to redirect_to(issue_templates_path(project: template.project.identifier))
      template.reload
      assert_match /updated/, flash[:notice]
      expect(template.descriptions.first.text).to eq "Text of an instruction field 2"
      expect(template.descriptions.first.position).to eq 1
      expect(template.descriptions.second.text).to eq "Text of an instruction field"
      expect(template.descriptions.second.position).to eq 2
    end
  end

  # create a template
  it "should add issue template through the init new template screen" do
    post :init, params: {:project_id => '1', :tracker_id => '1'}
    expect(response).to be_successful
    assert_template 'new'

    post :create, params: {:issue_template => { :tracker_id => '1',
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
    expect(response).to redirect_to(:controller => 'issue_templates', :action => 'index', :project => template.project.identifier)
  end

  context "PUT project_settings" do
    it "should succeed and update the templates associations to project" do

      project = Project.first
      template = IssueTemplate.last

      assert_difference -> { project.issue_templates.count }, 1 do
        put :project_settings, params: { :project_id => project.id, :project => { :issue_template_ids => [ template.id ] } }
      end

      expect(response).to redirect_to(settings_project_path(:id => project.identifier, :tab => :issue_templates))
      assert_match /updated/, flash[:notice]
    end
  end
end
