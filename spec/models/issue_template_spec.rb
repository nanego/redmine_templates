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

  it "should have many descriptions" do
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
    template = IssueTemplate.create(:project_id => 1,
                                    :tracker_id => 1,
                                    :status_id => 1,
                                    :author_id => 2,
                                    :subject => 'test_create',
                                    :template_title => 'New title template',
                                    :template_enabled => true,
                                    :template_project_ids => [1],
                                    :descriptions_attributes => [{
                                                                   :description => "Section description",
                                                                   :type => "IssueTemplateDescriptionSection",
                                                                   :position => 1
                                                                 }]
    )
    expect(template.valid?).to eq false
    expect(template.descriptions.size).to eq 1
    expect(template.descriptions.first).to_not be_persisted
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
                                    :descriptions_attributes => [{
                                                                   :text => "Consigne pour remplir le formulaire de création d'une demande",
                                                                   :type => "IssueTemplateDescriptionInstruction",
                                                                   :position => 1
                                                                 }]
    )
    expect(template.valid?).to eq true
    expect(template.descriptions.size).to eq 1
    expect(template.descriptions.first).to be_persisted
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
                                 :descriptions_attributes => [{
                                                                :type => "IssueTemplateDescriptionInstruction",
                                                                :position => 1
                                                              }]
    )
    expect(template.descriptions.size).to eq 0
  end

  context "has_descriptions_fields?" do
    it "should send true if template has descriptions" do
      template = IssueTemplate.new(:project_id => 1,
                                   :tracker_id => 1,
                                   :status_id => 1,
                                   :author_id => 2,
                                   :subject => 'test_create',
                                   :template_title => 'New title template',
                                   :template_enabled => true,
                                   :template_project_ids => [1],
                                   :split_description => "1",
                                   :descriptions_attributes => [{
                                                                  :title => "Section title",
                                                                  :description => "Section description",
                                                                  :type => "IssueTemplateDescriptionSection",
                                                                  :position => 1
                                                                }]
      )
      template.save
      template.reload
      expect(template.split_description).to be_truthy
      expect(template.descriptions).to_not be_empty
    end

    it "should send false if template hasn't got descriptions" do
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
      expect(template.descriptions).to be_empty
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
                                   :descriptions_attributes => [{
                                                                  :title => "Section title",
                                                                  :description => "Section description",
                                                                  :type => "IssueTemplateDescriptionSection",
                                                                  :position => 1
                                                                }]
      )

      expect(template.save).to be_truthy
      template.reload
      expect(template.descriptions.size).to eq 1
    end
  end
end
