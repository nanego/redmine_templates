require "spec_helper"

describe "IssueTemplate" do
  fixtures :projects, :users, :members, :member_roles, :roles,
           :trackers, :issue_statuses, :projects_trackers

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

  it "has many section groups" do
    t = IssueTemplate.reflect_on_association(:section_groups)
    expect(t.macro).to eq(:has_many)
  end

  it "should have many sections" do
    t = IssueTemplate.reflect_on_association(:sections)
    expect(t.macro).to eq(:has_many)
  end

  it "should save section if it has a title and a description" do
    template = IssueTemplate.create(:project_id => 1,
                                    :tracker_id => 1,
                                    :status_id => 1,
                                    :author_id => 2,
                                    :subject => 'test_create',
                                    :template_title => 'New title template',
                                    :template_enabled => true,
                                    :template_project_ids => [1],
                                    :section_groups_attributes => [{
                                                                     :title => "Section group title",
                                                                     :position => 1,
                                                                     sections_attributes: [
                                                                       {
                                                                         :title => "Section title",
                                                                         :description => "Section description",
                                                                         :type => "IssueTemplateSectionTextArea",
                                                                         :position => 1 }
                                                                     ]
                                                                   }]
    )
    expect(template.valid?).to eq true
    expect(template.sections.size).to eq 1
    expect(template.sections.first).to be_persisted
  end

  it "shouldn't save section with no title" do
    template = IssueTemplate.new(:project_id => 1,
                                 :tracker_id => 1,
                                 :status_id => 1,
                                 :author_id => 2,
                                 :subject => 'test_create',
                                 :template_title => 'New title template',
                                 :template_enabled => true,
                                 :template_project_ids => [1],
                                 :section_groups_attributes => [{
                                                                  :title => "Section group title",
                                                                  :position => 1,
                                                                  sections_attributes: [
                                                                    {
                                                                      :title => nil,
                                                                      :description => "Section description",
                                                                      :type => "IssueTemplateSectionTextArea",
                                                                      :position => 1 }
                                                                  ]
                                                                }]
    )
    expect(template.valid?).to eq false
    expect(template.save).to eq false
  end

  it "should save instruction if it has a text" do
    template = IssueTemplate.create(:project_id => 1,
                                    :tracker_id => 1,
                                    :status_id => 1,
                                    :author_id => 2,
                                    :subject => 'test_create',
                                    :template_title => 'New title template',
                                    :template_enabled => true,
                                    :template_project_ids => [1],
                                    :section_groups_attributes => [{
                                                                     :title => "Section group title",
                                                                     :position => 1,
                                                                     sections_attributes: [
                                                                       {
                                                                         :text => "Consigne pour remplir le formulaire de création d'une demande",
                                                                         :type => "IssueTemplateSectionInstruction",
                                                                         :position => 1 }
                                                                     ]
                                                                   }]
    )
    expect(template.valid?).to eq true
    expect(template.sections.size).to eq 1
    expect(template.sections.first).to be_persisted
  end

  it "shouldn't save instruction with no text" do
    template = IssueTemplate.new(:project_id => 1,
                                 :tracker_id => 1,
                                 :status_id => 1,
                                 :author_id => 2,
                                 :subject => 'test_create',
                                 :template_title => 'New title template',
                                 :template_enabled => true,
                                 :template_project_ids => [1],
                                 :section_groups_attributes => [{
                                                                  :title => "Section group title",
                                                                  :position => 1,
                                                                  sections_attributes: [
                                                                    {
                                                                      :type => "IssueTemplateSectionInstruction",
                                                                      :position => 1 }
                                                                  ]
                                                                }]
    )
    expect(template.sections.size).to eq 0
  end

  context "has_descriptions_fields?" do
    it "should send true if template has sections" do
      template = IssueTemplate.new(:project_id => 1,
                                   :tracker_id => 1,
                                   :status_id => 1,
                                   :author_id => 2,
                                   :subject => 'test_create',
                                   :template_title => 'New title template',
                                   :template_enabled => true,
                                   :template_project_ids => [1],
                                   :split_description => "1",
                                   :section_groups_attributes => [{
                                                                    :title => "Section group title",
                                                                    :position => 1,
                                                                    sections_attributes: [
                                                                      {
                                                                        :title => "Section title",
                                                                        :description => "Section description",
                                                                        :type => "IssueTemplateSectionTextArea",
                                                                        :position => 1 }
                                                                    ]
                                                                  }]
      )
      template.save
      template.reload
      expect(template.split_description).to be_truthy
      expect(template.sections).to_not be_empty
    end

    it "should send false if template hasn't got sections" do
      template = IssueTemplate.new(:project_id => 1,
                                   :tracker_id => 1,
                                   :status_id => 1,
                                   :author_id => 2,
                                   :subject => 'test_create',
                                   :template_title => 'New title template',
                                   :template_enabled => true,
                                   :template_project_ids => [1]
      )
      template.save
      template.reload
      expect(template.split_description).to be_falsey
      expect(template.sections).to be_empty
    end

    it "does NOT empty sections and instructions if split_description is unchecked" do
      template = IssueTemplate.new(:project_id => 1,
                                   :tracker_id => 1,
                                   :status_id => 1,
                                   :author_id => 2,
                                   :subject => 'test_create',
                                   :template_title => 'New title template',
                                   :template_enabled => true,
                                   :template_project_ids => [1],
                                   :split_description => "0",
                                   :section_groups_attributes => [{
                                                                    :title => "Section group title",
                                                                    :position => 1,
                                                                    sections_attributes: [
                                                                      {
                                                                        :title => "Section title",
                                                                        :description => "Section description",
                                                                        :type => "IssueTemplateSectionTextArea",
                                                                        :position => 1 }
                                                                    ]
                                                                  }]
      )

      expect(template.save).to be_truthy
      template.reload
      expect(template.sections.size).to eq 1
    end
  end

  context "Update relationship tables on cascading delete" do
    let(:template_test) {
      template_test = IssueTemplate.create(:project_id => 1,
                                           :tracker_id => 1,
                                           :status_id => 1,
                                           :author_id => 2,
                                           :subject => 'test_create',
                                           :description => 'IssueTest#test_create',
                                           :template_title => 'New title template',
                                           :template_enabled => true,
                                           :template_project_ids => [1]
      ) }

    it "when deleting a tracker" do
      tracker_test = Tracker.create!(:name => 'Test', :default_status_id => 1)
      template_test.tracker_id = tracker_test.id
      template_test.save
      tracker_test.destroy

      template_test.reload
      expect(template_test.tracker_id).to eq(0)
    end

    it "when deleting a issue status" do
      status_test = IssueStatus.create!(:name => 'Test')
      template_test.status_id = status_test.id
      template_test.save
      status_test.destroy

      template_test.reload
      expect(template_test.status_id).to eq(0)
    end

    it "when deleting a issue category" do
      category_test = IssueCategory.create(project: Project.find(1), name: "To Be Removed Issue Category")
      template_test.category_id = category_test.id
      template_test.save
      category_test.destroy
      template_test.reload

      expect(template_test.category_id).to be_nil
    end

    it "when deleting a author user" do
      user_test = User.create(:login => "test", :firstname => 'test', :lastname => 'test',
                              :mail => 'test.test@test.fr', :language => 'fr')
      template_test.author_id = user_test.id
      template_test.save

      user_test.destroy
      template_test.reload
      expect(template_test.author_id).to eq(User.anonymous.id)
    end

    it "when deleting a assigne_to user" do
      user_test = User.create(:login => "test", :firstname => 'test', :lastname => 'test',
                              :mail => 'test.test@test.fr', :language => 'fr')
      template_test.assigned_to_id = user_test.id
      template_test.save

      user_test.destroy
      template_test.reload
      expect(template_test.assigned_to_id).to be_nil
    end

    it "calculate issue_templates in the method objects_count" do
      priority_test = IssuePriority.all[5]
      expect(priority_test.objects_count).to eq(0)

      template_test.priority_id = priority_test.id
      template_test.save
      # Since there are objects_count is greater than 0, it does not accept removing priority
      expect(priority_test.issue_templates.count).to eq(1)
      expect(priority_test.issues.count).to eq(0)
      expect(priority_test.objects_count).to eq(1)
    end

    if Redmine::Plugin.installed?(:redmine_typologies)
      it "when deleting a typology" do
        typology_test = Typology.create(name: "Typo1")
        template_test.typology_id = typology_test.id
        template_test.save

        typology_test.destroy
        template_test.reload
        expect(template_test.typology_id).to be_nil
      end
    end

  end
end
