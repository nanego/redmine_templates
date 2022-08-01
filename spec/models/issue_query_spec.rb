require 'spec_helper'

describe "IssueQuery" do
  fixtures :issue_templates, :issues

  def find_issues_with_query(query)
    Issue.where(
      query.statement
    ).all
  end

  def create_issues_from_templates
    3.times do |i|
      Issue.create(:project_id => 1, :tracker_id => 1, :author_id => 1,
        :status_id => 1, :priority => IssuePriority.first,
        :subject => "Issue test#{i}",
        :issue_template_id => i + 1)
    end
  end

  it "should IssueQuery have available_filters issue_templates" do
    query = IssueQuery.new
    expect(query.available_filters).to include 'issue_template_id'
  end

  describe "should filter issues with issue_templates" do

    before do
      create_issues_from_templates
    end

    it "operator equal =" do
      query = IssueQuery.new(:name => '_', :filters => { 'issue_template_id' => { :operator => '=', :values => [1] } })
      result = find_issues_with_query(query)

      expect(result).to include Issue.last(3)[0]
      expect(result).not_to include Issue.last(3)[1]
      expect(result.count).to eq(1)
    end

    it "operator not equal !" do
      query = IssueQuery.new(:name => '_', :filters => { 'issue_template_id' => { :operator => '!', :values => [1] } })
      result = find_issues_with_query(query)

      expect(result).not_to include Issue.last(3)[0]
      expect(result).to include Issue.last(3)[1]
      expect(result).to include Issue.last(3)[2]
      expect(result.count).to eq(Issue.count - 1 )
    end

    it "operator all *" do
      query = IssueQuery.new(:name => '_', :filters => { 'issue_template_id' => { :operator => '*', :values => [''] } })
      result = find_issues_with_query(query)
      expect(result.count).to eq(3)
    end

    it "operator any !*" do
      query = IssueQuery.new(:name => '_', :filters => { 'issue_template_id' => { :operator => '!*', :values => [''] } })
      result = find_issues_with_query(query)
      expect(result.count).to eq(Issue.count - 3)
    end
  end
end