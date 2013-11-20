require File.expand_path('../../test_helper', __FILE__)

class IssueTemplatesTest < ActionController::IntegrationTest
  fixtures :users

  # create a template
  def test_add_issue_template
    log_user('admin', 'admin')
    post init_issue_template_path, :project_id => '1', :tracker_id => '1'
    assert_response :success
    assert_template 'new'

    post '/issue_templates', :issue_template => { :tracker_id => '1',
                                             :start_date => "2006-12-26",
                                             :priority_id => "4",
                                             :subject => "new test template subject",
                                             :description => "new template description",
                                             :done_ratio => "0",
                                             :due_date => "",
                                             :assigned_to_id => "",
                                             :template_title => "new template",
                                             :template_enabled => true,
                                             :project_id => '1',
                                             :status_id => '1'}

    # find created template
    template = IssueTemplate.find_by_template_title("new template")
    assert_kind_of IssueTemplate, template

    # check redirection
    assert_redirected_to :controller => 'issue_templates', :action => 'index', :project_id => template.project_id
    follow_redirect!
    assert_template 'index'
  end

end
