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



end
