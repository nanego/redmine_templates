class IssueTemplate < ActiveRecord::Base

  belongs_to :project
  belongs_to :tracker
  belongs_to :status, :class_name => 'IssueStatus', :foreign_key => 'status_id'
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :assigned_to, :class_name => 'Principal', :foreign_key => 'assigned_to_id'
  belongs_to :fixed_version, :class_name => 'Version', :foreign_key => 'fixed_version_id'
  belongs_to :priority, :class_name => 'IssuePriority', :foreign_key => 'priority_id'
  belongs_to :category, :class_name => 'IssueCategory', :foreign_key => 'category_id'

  validates_presence_of :subject, :tracker, :author, :project, :status, :template_title

  validates_length_of :subject, :maximum => 255
  # validates_inclusion_of :done_ratio, :in => 0..100
  validates :estimated_hours, :numericality => {:greater_than_or_equal_to => 0, :allow_nil => true, :message => :invalid}
  validates :start_date, :date => true
  validates :due_date, :date => true
  # validate :validate_issue, :validate_required_fields

  attr_accessible :project_id,
                  :tracker_id,
                  :subject,
                  :description,
                  :template_title,
                  :template_enabled,
                  :is_private,
                  :status_id,
                  :category_id,
                  :assigned_to_id,
                  :priority_id,
                  :fixed_version_id,
                  :start_date,
                  :due_date,
                  :done_ratio,
                  :estimated_hours,
                  # :custom_field_values,
                  # :custom_fields,
                  :lock_version,
                  :status_id,
                  :assigned_to_id,
                  :fixed_version_id,
                  :done_ratio,
                  :lock_version

  def allowed_target_projects
    Project.all(:conditions => Project.allowed_to_condition(User.current, :add_issues))
  end

end