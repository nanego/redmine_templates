require File.expand_path('../../test_helper', __FILE__)

class IssueTest < ActiveSupport::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles

  include Redmine::I18n

  def test_initialize
    template = IssueTemplate.new

    assert_equal 0, template.tracker_id
    assert_equal 0, template.author_id
    assert_nil template.assigned_to_id
    assert_nil template.category_id
    assert_equal 0, template.status_id
    assert_equal 0, template.priority_id
  end

  def test_create
    template = IssueTemplate.new(:project_id => 1,
                                 :tracker_id => 1,
                                 :status_id => 1,
                                 :subject => 'test_create',
                                 :description => 'IssueTest#test_create',
                                 :template_title => 'New title template',
                                 :template_enabled => true
                                )
    template.author_id = 2
    assert template.save
    template.reload
    assert_equal 'test_create', template.subject
  end

  def test_start_date_format_should_be_validated
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
      assert_include 'Start date is not a valid date', template.errors.full_messages, "No error found for invalid date #{invalid_date}"
    end
  end

  def test_due_date_format_should_be_validated
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
      assert_include 'Due date is not a valid date', template.errors.full_messages, "No error found for invalid date #{invalid_date}"
    end
  end

end
