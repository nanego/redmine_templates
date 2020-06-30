require "spec_helper"
require "active_support/testing/assertions"

describe IssuesController, type: :controller do
  include ActiveSupport::Testing::Assertions

  render_views

  fixtures :issue_templates, :issues, :projects, :users, :trackers, :issue_statuses

  before do
    @request.session[:user_id] = 1 # Admin
    User.current = User.find(1)
    Setting.default_language = "en"
  end

  context "POST create" do
    it "should show multiple description sections" do
      template = IssueTemplate.create( :project_id => 1,
                                       :tracker_id => 1,
                                       :status_id => 1,
                                       :author_id => 1,
                                       :subject => 'test_create',
                                       :template_title => 'New title template',
                                       :template_enabled => true,
                                       :template_project_ids => [1],
                                       :sections_attributes => [{
                                          :title => "Section title",
                                          :description => "Section description"
                                       }]
                                      )
      post :create, params: { :issue => { :issue_template_id => template.id,
                                          :subject => "Test",
                                          :project_id => 1,
                                          :tracker_id => 1,
                                          :priority_id => 4,
                                          :status_id => 1,
                                          :issue_template => {
                                            :sections_attributes => [{
                                              :text => "Test text"
                                            }]
                                          }
                                        }
                                  }
      expect(Issue.last.description).to eq("h1. Section title \r\n\r\n Test text")
    end
  end
end
