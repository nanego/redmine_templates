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

  context "Add a filter on the projects page: template activated" do

    it "should query use issue_template when index with column issue_template" do
      columns = ['name', 'issue_template_id']
      get :index, params: {:set_filter => 1, :c => columns}
      expect(response).to be_successful      
      # query should use specified columns
      query = assigns(:query)
      assert_kind_of ProjectQuery, query
      expect(query.column_names.map(&:to_s)).to eq columns
    end

    it "should ensure that the changes are compatible with the CSV" do
      
      template = IssueTemplate.create(:tracker_id => 1,
                                      :author_id => 2,
                                      :template_project_ids => [6],
                                      :status_id => 1,
                                      :subject => 'test_csv',
                                      :description => 'test_csv',
                                      :template_title => 'New title template',
                                      :template_enabled => true)
     
      columns = ['name', 'issue_template_id']

      get :index, params:{:set_filter => 1,
                          :f => ["issue_templates"],
                          :op => { "issue_templates" => "=" },
                          :v => {"issue_templates" => [template.id] },
                          :c => columns,
                          :format => 'csv'}
      expect(response).to be_successful
      expect(response.content_type).to eq 'text/csv; header=present'

      lines = response.body.chomp.split("\n")
      
      expect(lines[0].split(',')[1]).to eq "Active issue template"
      expect(lines[1].split(',')[0]).to eq Project.find(6).name
      expect(lines[1].split(',')[1]).to eq template.template_title
    end
  end

end
