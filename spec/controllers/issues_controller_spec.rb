require "spec_helper"
require "active_support/testing/assertions"

describe IssuesController, type: :controller do
  include ActiveSupport::Testing::Assertions

  render_views

  fixtures :projects,
           :users, :email_addresses, :user_preferences,
           :roles,
           :members,
           :member_roles,
           :issues,
           :issue_statuses,
           :issue_relations,
           :versions,
           :trackers,
           :projects_trackers,
           :issue_categories,
           :enabled_modules,
           :enumerations,
           :attachments,
           :workflows,
           :custom_fields,
           :custom_values,
           :custom_fields_projects,
           :custom_fields_trackers,
           :time_entries,
           :journals,
           :journal_details,
           :queries,
           :repositories,
           :changesets,
           :watchers

  include Redmine::I18n

  before do
    @request.session[:user_id] = 1 # Admin
    User.current = User.find(1)
    Setting.default_language = "en"
  end

  let(:template) do
    IssueTemplate.create(
      :project_id => 1,
      :tracker_id => 3,
      :status_id => 2,
      :author_id => 2,
      :subject => 'test_create',
      :template_title => 'New title template',
      :template_enabled => true,
      :template_project_ids => [1],
      :sections_attributes => [{
        :title => "Section title",
        :description => "Section description"
      },
       {:title => "Second section title",
        :description => "Second section description"
       }
      ]
    )
  end

  context "POST create" do
    it "should show multiple description sections" do
      @request.session[:user_id] = 2
      assert_difference('Issue.count', 1) do
        post :create, :params => {
          :project_id => 1,
          :issue => {
            :tracker_id => 3,
            :status_id => 2,
            :subject => 'This is the test_new issue',
            :description => 'This is the description',
            :priority_id => 5,
            :issue_template_id => template.id,
            :issue_template => {
              :sections_attributes => {
                "0" => {
                  :text => "Test text"
                }
              },
            },
          },
        }
      end

      issue = Issue.find_by_subject('This is the test_new issue')
      expect(issue).not_to be_nil
      expect(issue.description).to eq("h1. Section title \r\n\r\nTest text\r\n\r\n")
    end

    it "joins multiple sections into one description" do
      @request.session[:user_id] = 2
      assert_difference('Issue.count', 1) do
        post :create, :params => {
            :project_id => 1,
            :issue => {
                :tracker_id => 3,
                :status_id => 2,
                :subject => 'This is the test_new issue',
                :description => 'This is the description',
                :priority_id => 5,
                :issue_template_id => template.id,
                :issue_template => {
                    :sections_attributes => {
                        "0" => {
                            :text => "Test text"
                        },
                        "1" => {
                            :text => "Second test text"
                        }
                    },
                },
            },
        }
      end

      issue = Issue.find_by_subject('This is the test_new issue')
      expect(issue).not_to be_nil
      expect(issue.description).to eq("h1. Section title \r\n\r\nTest text\r\n\r\nh1. Second section title \r\n\r\nSecond test text\r\n\r\n")
    end
  end
end
