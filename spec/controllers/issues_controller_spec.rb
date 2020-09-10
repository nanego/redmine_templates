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
           :watchers,
           :issue_templates, :issue_template_descriptions, :issue_templates_projects

  include Redmine::I18n

  before do
    @request.session[:user_id] = 2
    User.current = User.find(1)
    Setting.default_language = "en"
  end

  let(:template) { IssueTemplate.find(4) }
  let(:template_with_instruction) { IssueTemplate.find(5) }

  context "POST create" do
    it "shows multiple description sections" do
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
                    :descriptions_attributes => {
                        "0" => {
                            :text => "Test text"
                        }
                    },
                },
            },
        }
      end

      issue = Issue.last
      expect(issue).not_to be_nil
      expect(issue.description).to eq("\r\n*Section title :* \r\nTest text\r\n")
    end

    it "joins multiple sections into one description" do
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
                    :descriptions_attributes => {
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

      issue = Issue.last
      expect(issue).not_to be_nil
      expect(issue.description).to eq("\r\n*Section title :* \r\nTest text\r\n\r\n*Second section title without Toolbar :* \r\nSecond test text\r\n")
    end

    it "uses empty_value if text field is empty" do
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
                    :descriptions_attributes => {
                        "0" => {
                            :text => "Test text",
                            :empty_value => "No data"
                        },
                        "1" => {
                            :text => "",
                            :empty_value => "Nothing to say"
                        }
                    },
                },
            },
        }
      end

      issue = Issue.last
      expect(issue).not_to be_nil
      expect(issue.description).to eq("\r\n*Section title :* \r\nTest text\r\n\r\n*Second section title without Toolbar :* \r\nNothing to say\r\n")
    end

    it "does not join instructions into description" do
      assert_difference('Issue.count', 1) do
        post :create, :params => {
            :project_id => 1,
            :issue => {
                :tracker_id => 3,
                :status_id => 2,
                :subject => 'This is the test_new issue',
                :description => 'Ignore default description',
                :priority_id => 5,
                :issue_template_id => template_with_instruction.id,
                :issue_template => {
                    :descriptions_attributes => {
                        "0" => {
                            :text => "Text in a section field"
                        }
                    },
                },
            },
        }
      end

      issue = Issue.last
      expect(issue).not_to be_nil
      expect(issue.description).to eq("")
    end

    it "sends a notification by mail with multiple sections concatenated into one description" do
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
                  :descriptions_attributes => {
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
      expect(ActionMailer::Base.deliveries).to_not be_empty

      issue = Issue.last
      expect(issue).not_to be_nil
      expect(issue.description).to_not eq 'This is the description'
      expect(issue.description).to eq("h2. Section title \r\n\r\nTest text\r\n\r\nh2. Second section title without Toolbar \r\n\r\nSecond test text\r\n\r\n")

      mail = ActionMailer::Base.deliveries.last
      mail.parts.each do |part|
        expect(part.body.raw_source).to include("Test text")
        expect(part.body.raw_source).to include("Second test text")
      end
    end

  end
end
