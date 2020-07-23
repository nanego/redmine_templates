require "spec_helper"
require "active_support/testing/assertions"

describe ProjectsController, type: :controller do
  include ActiveSupport::Testing::Assertions

  render_views

  fixtures :issue_templates, :issue_templates_projects, :users, :projects

  before do
    @request.session[:user_id] = 1 #=> admin ; permissions are hard...
  end

  context "POST copy project" do
    it "should copy available issue templates" do
      source_project = Project.find(2)
      assert_difference 'Project.count' do
        post :copy, :params => {
            :id => source_project.id,
            :project => {
                :name => 'Copy with templates',
                :identifier => 'copy-with-templates'
            },
            :only => %w(issues versions issue_templates)
        }
      end
      new_project = Project.find('copy-with-templates')
      assert_equal source_project.issue_templates, new_project.issue_templates, "All issue_templates were not copied"
      assert_equal IssueTemplate.where(id: [1, 2]).order("custom_form desc, tracker_id desc, usage desc").to_a, new_project.issue_templates.to_a
    end
  end

end
