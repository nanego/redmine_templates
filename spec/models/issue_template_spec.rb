require "spec_helper"

describe "Issue" do
  fixtures :projects, :users, :members, :member_roles, :roles,
           :trackers, :issue_statuses

  include Redmine::I18n

  it "should initialize" do
    template = IssueTemplate.new

    expect(template.tracker_id).to eq 0
    expect(template.author_id).to eq 0
    expect(template.assigned_to_id).to be_nil
    expect(template.category_id).to be_nil
    expect(template.status_id).to eq 0
    expect(template.priority_id).to eq 0
  end

  it "should create" do
    template = IssueTemplate.new(:project_id => 1,
                                 :tracker_id => 1,
                                 :status_id => 1,
                                 :subject => 'test_create',
                                 :description => 'IssueTest#test_create',
                                 :template_title => 'New title template',
                                 :template_enabled => true,
                                 :template_project_ids => [1]
                                )
    template.author_id = 2
    assert template.save
    template.reload
    expect(template.subject).to eq 'test_create'
  end

  it "should start date format should be validated" do
    set_language_if_valid 'en'
    ['2012', 'ABC', '2012-15-20'].each do |invalid_date|
      template = IssueTemplate.new(:project_id => 1,
                                   :tracker_id => 1,
                                   :status_id => 1,
                                   :subject => 'test_create',
                                   :description => 'IssueTest#test_create',
                                   :template_title => 'New title template',
                                   :template_enabled => true,
                                   :start_date => invalid_date)
      template.author_id = 2
      assert !template.valid?
      expect(template.errors.full_messages).to include('Start date is not a valid date')
    end
  end

  it "should due date format should be validated" do
    set_language_if_valid 'en'
    ['2012', 'ABC', '2012-15-20'].each do |invalid_date|
      template = IssueTemplate.new(:project_id => 1,
                                   :tracker_id => 1,
                                   :status_id => 1,
                                   :subject => 'test_create',
                                   :description => 'IssueTest#test_create',
                                   :template_title => 'New title template',
                                   :template_enabled => true,
                                   :due_date => invalid_date)
      template.author_id = 2
      assert !template.valid?
      expect(template.errors.full_messages).to include('Due date is not a valid date')
    end
  end

end
