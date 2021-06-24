require 'spec_helper'

describe "ProjectQuery" do
  fixtures :issue_templates, :issue_template_projects, :users, :projects

  before do
    User.current = User.find(1)
  end

  def find_projects_with_query(query)
    Project.where(
        query.statement
    ).all
  end

  def add_new_issue_template
    template = IssueTemplate.create(:tracker_id => 1,
                                    :author_id => 2,
                                    :template_project_ids => [6],
                                    :status_id => 1,
                                    :subject => 'test_operator',
                                    :description => 'test_operator',
                                    :template_title => 'New title test_operator',
                                    :template_enabled => true)
  end

  it "should ProjectQuery have available_filters issue_templates" do
    query = ProjectQuery.new
    expect(query.available_filters).to include 'issue_templates'
  end 

  describe "should filter projects with issue_templates" do
    it "operator equal =" do
      add_new_issue_template
      project = Project.find(2)
      query = ProjectQuery.new(:name => '_', :filters => { 'issue_templates' => {:operator => '=', :values => [1] } })    
      result = find_projects_with_query(query)
      expect(result).to include project
    end

    it "operator not equal !" do
      project = Project.find(2)
      query = ProjectQuery.new(:name => '_', :filters => { 'issue_templates' => {:operator => '!', :values => [1] } })    
      result = find_projects_with_query(query)
      expect(result).not_to include project
    end

    it "operator all *" do
      add_new_issue_template
      query = ProjectQuery.new(:name => '_', :filters => { 'issue_templates' => {:operator => '*', :values => [1] } })    
      result = find_projects_with_query(query)       
      expect(result.count).to eq 2
    end

    it "operator any !*" do    
      query = ProjectQuery.new(:name => '_', :filters => { 'issue_templates' => {:operator => '!*', :values => [1] } })    
      result = find_projects_with_query(query)
      expect(result.count).to eq 5
    end
  end  
end
