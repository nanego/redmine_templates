require "spec_helper"
require "active_support/testing/assertions"

describe ProjectsController, type: :controller do
  include ActiveSupport::Testing::Assertions

  render_views

  self.fixture_path = File.dirname(__FILE__) + "/../fixtures/"
  fixtures :issue_templates

  before do
    @request.session[:user_id] = 1 #=> admin ; permissions are hard...
  end

  context "POST copy project" do
    it "should copy available issue templates" do
      assert_difference 'Project.count' do
        post :copy, :params => {
            :id => 1,
            :project => {
                :name => 'Copy with templates',
                :identifier => 'copy-with-templates'
            },
            :only => %w(issues versions issue_templates)
        }
      end
      project = Project.find('copy-with-templates')
      source = Project.find(1)
      assert_equal IssueTemplate.where(id: 1), project.issue_templates
      assert_equal source.issue_templates.count, project.issue_templates.count, "All issue_templates were not copied"
    end
  end

end
