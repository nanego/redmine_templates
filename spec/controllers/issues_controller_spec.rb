require "spec_helper"
require "active_support/testing/assertions"
require File.dirname(__FILE__) + "/../support/issue_template_spec_helpers"

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
           :issue_templates, :issue_template_section_groups, :issue_template_sections, :issue_template_projects

  include Redmine::I18n

  before do
    @request.session[:user_id] = 2
    User.current = User.find(1)
    Setting.default_language = "en"
  end

  let(:template) { IssueTemplate.find(4) }
  let(:template_with_instruction) { IssueTemplate.find(5) }
  let(:template_with_repeatable_sections) { IssueTemplate.find(6) }

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
              :section_groups_attributes => {
                "3" => {
                  "0" => {
                    :sections_attributes => {
                      "3" => {
                        text: "Test text",
                        empty_value: ""
                      }
                    }
                  }
                }
              }
            }
          }
        }
      end

      issue = Issue.last
      expect(issue).not_to be_nil
      expect(issue.description).to eq("\r\n-----\r\n\r\n*Section title :* \r\nTest text\r\n")
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
              :section_groups_attributes => {
                "3" => {
                  "0" => {
                    :sections_attributes => {
                      "3" => {
                        text: "Test text",
                        empty_value: "No data"
                      },
                      "4" => {
                        text: "Second test text",
                        empty_value: "Nothing to say"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      end

      issue = Issue.last
      expect(issue).not_to be_nil
      expect(issue.description).to eq("\r\n-----\r\n\r\n*Section title :* \r\nTest text\r\n\r\n*Second section title without Toolbar :* \r\nSecond test text\r\n")
    end

    it "joins multiple sections into one description and substitute variables with values" do
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
              :section_groups_attributes => {
                "3" => {
                  "0" => {
                    :sections_attributes => {
                      "3" => {
                        text: "Test text {tracker}",
                        empty_value: "No data"
                      },
                      "4" => {
                        text: "Second test text",
                        empty_value: "Nothing to say"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      end

      issue = Issue.last
      expect(issue).not_to be_nil
      expect(issue.description).to eq("\r\n-----\r\n\r\n*Section title :* \r\nTest text Support request\r\n\r\n*Second section title without Toolbar :* \r\nSecond test text\r\n")
    end

    it "joins multiple sections and use them to generate the subject" do
      template.autocomplete_subject = true
      template.subject = "{section_3} -> {section_4}"
      template.save

      assert_difference('Issue.count', 1) do
        post :create, :params => {
          :project_id => 1,
          :issue => {
            :tracker_id => 3,
            :status_id => 2,
            :description => 'This is the description',
            :priority_id => 5,
            :issue_template_id => template.id,
            :issue_template => {
              :section_groups_attributes => {
                "3" => {
                  "0" => {
                    :sections_attributes => {
                      "3" => {
                        text: "Test text",
                        empty_value: "No data"
                      },
                      "4" => {
                        text: "Second test text",
                        empty_value: "Nothing to say"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      end

      issue = Issue.last
      expect(issue).not_to be_nil
      expect(issue.subject).to eq("Test text -> Second test text")
      expect(issue.description).to eq("\r\n-----\r\n\r\n*Section title :* \r\nTest text\r\n\r\n*Second section title without Toolbar :* \r\nSecond test text\r\n")
    end

    it "allows repeatable sections and joins them into one description" do
      assert_difference('Issue.count', 1) do
        post :create, :params => {
          :project_id => 1,
          :issue => {
            :tracker_id => 3,
            :status_id => 2,
            :subject => 'This is the test_new issue',
            :description => 'This is the description',
            :priority_id => 5,
            :issue_template_id => template_with_repeatable_sections.id,
            :issue_template => {
              :section_groups_attributes => {
                "5" => {
                  "0" => {
                    :sections_attributes => {
                      "13" => {
                        text: "First line"
                      },
                      "15" => {
                        text: "2021-01-01"
                      },
                      "16" => {
                        text: "Long first text..."
                      },
                      "17" => {
                        text: "1"
                      },
                      "18" => {
                        "0": "1",
                        "1": "0"

                      },
                      "19" => {
                        "0": '1',
                        "1": '0'

                      },
                      "20" => {
                        text: "val1"
                      }
                    }
                  },
                  "123456" => {
                    :sections_attributes => {
                      "13" => {
                        text: "second line"
                      },
                      "15" => {
                        text: "2020-12-31"
                      },
                      "16" => {
                        text: "Second content"
                      },
                      "17" => {
                        text: "0"
                      },
                      "18" => {
                        "0": '0',
                        "1": '1'
                      },
                      "19" => {
                        "0": '0',
                        "1": '1'
                      },
                      "20" => {
                        text: "val2"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      end

      issue = Issue.last
      expect(issue).not_to be_nil
      expect(issue.description).to eq(<<~DESCRIPTION
        \r\n-----\r
        \r\nh2. Title repeatable group\r\n\r
        \r\n*New one-line field :* First line\r
        \r\n*New date field :* 2021-01-01\r
        \r\n*New long text area :* \r\nLong first text...\r
        \r\n*Checkbox field :* Yes\r
        \r\n*Select field :* \r
        * value1 : Yes \r
        * value2 : No \r
        \r\n*New select field displaying only selected values :* \r
        * value-1 : Yes \r
        \r\n*Select Radio field :* val1\r
        \r\n-----\r
        \r\nh2. Title repeatable group\r\n\r
        \r\n*New one-line field :* second line\r
        \r\n*New date field :* 2020-12-31\r
        \r\n*New long text area :* \r\nSecond content\r
        \r\n*Checkbox field :* No\r
        \r\n*Select field :* \r
        * value1 : No \r
        * value2 : Yes \r
        \r\n*New select field displaying only selected values :* \r
        * value-2 : Yes \r
        \r\n*Select Radio field :* val2\r
                                   DESCRIPTION
                                   )
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
              :section_groups_attributes => {
                "3" => {
                  "0" => {
                    :sections_attributes => {
                      "3" => {
                        text: "Test text",
                        empty_value: "No data"
                      },
                      "4" => {
                        text: "",
                        empty_value: "Nothing to say"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      end

      issue = Issue.last
      expect(issue).not_to be_nil
      expect(issue.description).to eq("\r\n-----\r\n\r\n*Section title :* \r\nTest text\r\n\r\n*Second section title without Toolbar :* \r\nNothing to say\r\n")
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
              :section_groups_attributes => {
                "4" => {
                  "0" => {
                    :sections_attributes => {
                      "6" => {
                        text: "Text in a section field"
                      }
                    }
                  }
                }
              }
            }
          }
        }
      end

      issue = Issue.last
      expect(issue).not_to be_nil
      expect(issue.description).to eq("\r\n-----\r\n")
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
            :section_groups_attributes => {
              "3" => {
                "0" => {
                  :sections_attributes => {
                    "3" => {
                      text: "Test text",
                      empty_value: "No data"
                    },
                    "4" => {
                      text: "Second test text",
                      empty_value: "Nothing to say"
                    }
                  }
                }
              }
            }
          }
        }
      }
      expect(ActionMailer::Base.deliveries).to_not be_empty

      issue = Issue.last
      expect(issue).not_to be_nil
      expect(issue.description).to_not eq 'This is the description'
      expect(issue.description).to eq("\r\n-----\r\n\r\n*Section title :* \r\nTest text\r\n\r\n*Second section title without Toolbar :* \r\nSecond test text\r\n")

      mail = ActionMailer::Base.deliveries.last
      mail.parts.each do |part|
        expect(part.body.raw_source).to include("Test text")
        expect(part.body.raw_source).to include("Second test text")
      end
    end

  end

  context "Add a filter on the issues page: template used" do

    it "should query use issue_template when index with column issue_template_id" do
      columns = ['subject', 'issue_template_id']
      get :index, params: { :set_filter => 1, :c => columns }
      expect(response).to be_successful
      # query should use specified columns
      query = assigns(:query)
      assert_kind_of IssueQuery, query
      expect(query.column_names.map(&:to_s)).to eq columns
    end

    it "should ensure that the changes are compatible with the CSV" do
      issuetemplate = IssueTemplate.find(1)
      issue = Issue.create(:project_id => 1, :tracker_id => 1, :author_id => 1,
                           :status_id => 1, :priority => IssuePriority.first,
                           :subject => "Issue test",
                           :issue_template_id => issuetemplate.id)

      columns = ["subject", "issue_template"]

      get :index, params: { :set_filter => 1,
                            :f => ["issue_template_id"],
                            :op => { "issue_template_id" => "=" },
                            :v => { "issue_template_id" => ["1"] },
                            :c => columns,
                            :format => 'csv' }

      expect(response).to be_successful
      expect(response.content_type).to eq 'text/csv; header=present'

      lines = response.body.chomp.split("\n")

      expect(lines[0].split(',')[0]).to eq "#"
      expect(lines[0].split(',')[1]).to eq "Subject"
      expect(lines[0].split(',')[2]).to eq "Template used"
      expect(lines[1].split(',')[0]).to eq issue.id.to_s
      expect(lines[1].split(',')[1]).to eq issue.subject
      expect(lines[1].split(',')[2]).to eq issuetemplate.template_title
    end
  end

  context "should sort by issue_template title" do
    before do
      create_issues_from_templates
    end

    it "sort asc" do
      columns = ['subject', 'issue_template_id']
      get(
        :index,
        :params => {
          :set_filter => 1,
          :c => columns,
          :group_by => 'issue_template',
          :sort => 'issue_template,id:desc'
        }
      )

      expect(response).to be_successful
      templetes = issues_in_list.map(&:issue_template)
      expect(templetes.first.template_title).to eq(IssueTemplate.find(1).template_title)
    end

    it "sort desc" do
      columns = ['subject', 'issue_template_id']
      get(
        :index,
        :params => {
          :set_filter => 1,
          :c => columns,
          :group_by => 'issue_template',
          :sort => 'issue_template:desc,id:desc'
        }
      )

      expect(response).to be_successful
      templetes = issues_in_list.map(&:issue_template)
      expect(templetes.last.template_title).to eq(IssueTemplate.find(1).template_title)
    end
  end
end
