require "spec_helper"
require "active_support/testing/assertions"

describe ProjectsController, type: :controller do
  include ActiveSupport::Testing::Assertions

  render_views

  fixtures :issue_templates, :issue_template_projects, :users, :projects

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
      expect(new_project.issue_templates.size).to eq 6
    end
  end

  context "PUT project settings" do
    it "should succeed and update the templates associations to project" do

      project = Project.first
      template = IssueTemplate.last

      assert_difference -> { project.issue_templates.count }, 1 do
        put :update, params: {:id => project.id,
                              :project => {:issue_template_ids => [template.id]},
                              :tab => :issue_templates
        }
      end

      expect(response).to redirect_to(settings_project_path(:id => project.identifier, :tab => :issue_templates))
      expect(flash[:notice]).to match /Successful update/
    end
  end

end
