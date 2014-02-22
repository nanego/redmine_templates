require File.expand_path('../../test_helper', __FILE__)

class IssueTemplatesControllerTest < ActionController::TestCase

  # NB: setting a specific fixture_path here prevents us from declaring
  # explicitly all needed fixtures because Rails only have one fixture
  # directory. As we don't declare all fixtures explicitly, 1/ we cannot
  # run this test file alone and 2/ it may break depending on which other
  # tests ran before.
  #
  # TODO(jbbarth): see if we can remove this line and copy this fixture file
  # in the core's test/fixtures/ directory when we prepare the test database.
  # This is what I generally do in other plugins but there may be better ideas.
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
      post :create, :issue_template => { subject: "New issue", project_id: 1, tracker_id: 1, status_id: 1, template_title: "New template", project_ids: [1] }
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
      post :create, :issue_template => { subject: "New issue", project_id: 1, tracker_id: 1, status_id: 1, template_title: "New template", project_ids: [1] }
      template = IssueTemplate.last
      assert_no_difference('IssueTemplate.count') do
        put :update, :id => template.id, issue_template: { subject: "Modified subject" }
      end
      assert_redirected_to issue_templates_path(project_id: template.project_id)
      template.reload
      assert_match /updated/, flash[:notice]
      assert_equal "Modified subject", template.subject
      #assert_equal 1, template.project_id
      #assert_equal 2, template.tracker_id
      #assert_equal 6, template.priority_id
      #assert_equal 1, template.category_id
    end
  end



end
