class IssueTemplate < ActiveRecord::Base
  include Redmine::SafeAttributes

  acts_as_customizable

  belongs_to :project
  belongs_to :tracker
  belongs_to :status, :class_name => 'IssueStatus', :foreign_key => 'status_id'
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :assigned_to, :class_name => 'Principal', :foreign_key => 'assigned_to_id'
  belongs_to :fixed_version, :class_name => 'Version', :foreign_key => 'fixed_version_id'
  belongs_to :priority, :class_name => 'IssuePriority', :foreign_key => 'priority_id'
  belongs_to :category, :class_name => 'IssueCategory', :foreign_key => 'category_id'

  has_and_belongs_to_many :template_projects, class_name: 'Project', join_table: 'issue_templates_projects'

  has_and_belongs_to_many :secondary_projects, class_name: 'Project', join_table: 'multiprojects_issue_templates'

  validates_presence_of :template_title, :subject, :tracker, :author, :project, :status, :template_projects

  validates_uniqueness_of :template_title
  validates_length_of :subject, :maximum => 255
  # validates_inclusion_of :done_ratio, :in => 0..100
  validates :estimated_hours, :numericality => {:greater_than_or_equal_to => 0, :allow_nil => true, :message => :invalid}
  validates :start_date, :date => true
  validates :due_date, :date => true
  # validate :validate_issue, :validate_required_fields

  safe_attributes :template_project_ids,
                  :secondary_project_ids,
                  :project_id,
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
                  :custom_field_values,
                  :custom_fields,
                  :lock_version,
                  :status_id,
                  :assigned_to_id,
                  :fixed_version_id,
                  :done_ratio,
                  :lock_version,
                  :usage,
                  :authorized_viewers

  def allowed_target_projects
    Project.where(Project.allowed_to_condition(User.current, :add_issues))
  end

  def disabled_projects
    Project.all - Project.includes(:enabled_modules).where("enabled_modules.name" => :issue_templates)
  end

  def assignable_users
    users = []
    users << project.assignable_users.to_a if project
    users << author if author
    users << assigned_to if assigned_to
    users.uniq.sort
  end

  # Overrides Redmine::Acts::Customizable::InstanceMethods#available_custom_fields
  def available_custom_fields
    (project && tracker) ? (project.all_issue_custom_fields & tracker.custom_fields.all) : []
  end

  # Returns the custom_field_values that can be edited by the given user
  def editable_custom_field_values(user=nil)
    custom_field_values.reject do |value|
      read_only_attribute_names(user).include?(value.custom_field_id.to_s)
    end
  end

  # Returns the names of attributes that are read-only for user or the current user
  # For users with multiple roles, the read-only fields are the intersection of
  # read-only fields of each role
  # The result is an array of strings where sustom fields are represented with their ids
  def read_only_attribute_names(user=nil)
    workflow_rule_by_attribute(user).reject {|attr, rule| rule != 'readonly'}.keys
  end

  # Returns a hash of the workflow rule by attribute for the given user # TODO : Cleanup these methods
  def workflow_rule_by_attribute(user=nil)
    return @workflow_rule_by_attribute if @workflow_rule_by_attribute && user.nil?

    user_real = user || User.current
    roles = user_real.admin ? Role.all : user_real.roles_for_project(project)
    return {} if roles.empty?

    result = {}
    workflow_permissions = WorkflowPermission.where(:tracker_id => tracker_id, :old_status_id => status_id, :role_id => roles.map(&:id)).all
    if workflow_permissions.any?
      workflow_rules = workflow_permissions.inject({}) do |h, wp|
        h[wp.field_name] ||= []
        h[wp.field_name] << wp.rule
        h
      end
      workflow_rules.each do |attr, rules|
        next if rules.size < roles.size
        uniq_rules = rules.uniq
        if uniq_rules.size == 1
          result[attr] = uniq_rules.first
        else
          result[attr] = 'required'
        end
      end
    end
    @workflow_rule_by_attribute = result if user.nil?
    result
  end

  def authorized_viewer_ids
    "#{authorized_viewers}".split('|').reject(&:blank?).map(&:to_i)
  end

end
