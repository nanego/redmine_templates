require File.expand_path('../../test_helper', __FILE__)

class IssueTemplatesControllerTest < ActionController::TestCase

  self.fixture_path = File.dirname(__FILE__) + "/../fixtures/"
  fixtures :issue_templates

  setup do
    @request.session[:user_id] = 1 #=> admin ; permissions are hard...
  end

  context "POST init" do
    should "fail without project id" do
      post :init
      assert_response 404
    end

    should "succeed with project id" do
      post :init, :project_id => 1
      assert_response :success
      assert_template 'new'
    end
  end

  context "POST create" do
    should "succeed and assign a new template" do
      post :create, :issue_template => { subject: "New issue", project_id: 1, tracker_id: 1, status_id: 1, template_title: "New template" }
      assert_redirected_to issue_templates_path(project_id: 1)
      assert_equal "New issue template successfully created!", flash[:notice]
      assert_equal "New issue", IssueTemplate.last.try(:subject)
    end
  end

  context "GET edit" do
    should "succeed with an id" do
      get :edit, id: IssueTemplate.first.id
      assert_response :success
      assert_template 'edit'
    end
  end

  context "PUT update" do
    should "succeed and update the first template" do
      post :create, :issue_template => { subject: "New issue", project_id: 1, tracker_id: 1, status_id: 1, template_title: "New template" }
      template = IssueTemplate.last
      put :update, :id => template.id, issue_template: { subject: "Modified subject" }
      assert_redirected_to issue_templates_path(project_id: template.project_id)
      template.reload
      assert_match /updated/, flash[:notice]
      assert_equal "Modified subject", template.subject
    end
  end

end
