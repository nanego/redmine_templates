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
end
