require_relative 'issue_template_description'

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

  has_many :issues

  has_many :descriptions, -> { order(:position) }, :class_name => "IssueTemplateDescription", :dependent => :destroy
  accepts_nested_attributes_for :descriptions, :reject_if => :description_is_empty?, :allow_destroy => true

  has_many :section_groups, -> { order(:position) }, :class_name => 'IssueTemplateSectionGroup', :dependent => :destroy
  accepts_nested_attributes_for :section_groups, :reject_if => :section_group_is_empty?, :allow_destroy => true
  has_many :sections, :through => :section_groups

  has_many :issue_template_projects, dependent: :destroy
  has_many :template_projects, through: :issue_template_projects, source: :project

  has_many :template_projects_by_attributes, -> { select(:id, :name) }, through: :issue_template_projects, source: :project
  has_many :issues_by_attributes, -> { select(:issue_template_id) }, class_name: 'Issue'
  belongs_to :tracker_by_attributes, -> { select(:id, :name) }, class_name: 'Tracker', :foreign_key => 'tracker_id'

  if Redmine::Plugin.installed?(:redmine_multiprojects_issue)
    has_and_belongs_to_many :secondary_projects, class_name: 'Project', join_table: 'multiprojects_issue_templates'
  end

  validates_presence_of :template_title, :tracker, :author, :status
  validates_presence_of :template_projects, unless: :skip_template_projects_validation
  validates_length_of :subject, :maximum => 255
  # validates_inclusion_of :done_ratio, :in => 0..100

  validates :estimated_hours, :numericality => { :greater_than_or_equal_to => 0, :allow_nil => true, :message => :invalid }
  validates :start_date, :date => true
  validates :due_date, :date => true
  # validate :validate_issue, :validate_required_fields

  scope :displayed_on_overview, -> { active.where(show_on_overview: true) }
  scope :active, -> { where(template_enabled: true) }

  #to avoid fires update without waiting for the save or update call, we add these 3 attributtes
  validates_presence_of :assignable_projects, if: :assignable_projects_validation
  attr_accessor :assignable_projects, :skip_template_projects_validation, :assignable_projects_validation

  if Redmine::Plugin.installed?(:redmine_multiprojects_issue)
    attr_accessor :assignable_secondary_projects
  end

  safe_attributes :project_id,
                  :tracker_id,
                  :subject,
                  :description,
                  :template_title,
                  :template_description,
                  :template_image,
                  :template_enabled,
                  :show_on_overview,
                  :hide_file_attachment,
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
                  :usage,
                  :authorized_viewers,
                  :custom_form,
                  :custom_form_path,
                  :tracker_read_only,
                  :descriptions_attributes,
                  :section_groups_attributes,
                  :split_description,
                  :typology_id,
                  :autocomplete_subject

  def to_s
    template_title
  end

  def validate_custom_field_values
    # Skip custom values validation when saving templates
  end

  def title_with_tracker
    if template_title == tracker.name
      "[#{tracker}]"
    else
      "[#{tracker}] #{template_title}"
    end
  end

  def has_been_deleted?
    IssueTemplate.where(id: self.id).blank?
  end

  def allowed_target_projects
    Project.active
  end

  def allowed_for?(project:, user: User.current)
    Issue.allowed_target_trackers(project, user).include?(self.tracker) && self.template_projects.include?(project)
  end

  def self.allowed_target_projects_by_attributes
    Project.active_by_attributes
  end

  def disabled_projects
    Project.all - Project.includes(:enabled_modules).where("enabled_modules.name" => :issue_templates)
  end

  def assignable_users
    if template_projects.any? && template_projects.size < 4
      users = template_projects.map(&:assignable_users).flatten.uniq
    else
      users = []
    end
    users << author if author
    users << assigned_to if assigned_to
    users.uniq.sort
  end

  # Overrides Redmine::Acts::Customizable::InstanceMethods#available_custom_fields
  def available_custom_fields
    available_custom_fields = []
    assignable_projects&.each do |project|
      available_custom_fields |= project.all_issue_custom_fields.to_a
    end
    available_custom_fields |= tracker.custom_fields.all.to_a if tracker.present?
    available_custom_fields
  end

  def authorized_viewer_ids
    "#{authorized_viewers}".split('|').reject(&:blank?).map(&:to_i)
  end

  def assigned_to_function_id
    nil # TODO Make templates compatible with this functionality
  end

  def description_is_empty?(attributes)
    persisted = attributes["id"].present?
    case attributes["type"]
    when IssueTemplateDescriptionInstruction.name
      empty = attributes["text"].blank?
    end
    return (!persisted && empty)
  end

  def section_group_is_empty?(attributes)
    persisted = attributes["id"].present?
    has_no_title = attributes["title"].blank?
    has_no_sections = attributes["sections_attributes"].nil? || attributes["sections_attributes"].reject { |id, section| id == "$id_section$" }.blank?
    return (!persisted && has_no_title && has_no_sections)
  end

  def safe_attribute_names(user = nil)
    names = super
    names -= disabled_core_fields
    names
  end

  def disabled_core_fields
    tracker ? tracker.disabled_core_fields : []
  end

  # Returns a new unsaved Template instance with attributes copied from +template+
  def self.copy_from(template)
    template = template.is_a?(IssueTemplate) ? template : IssueTemplate.find(template)
    # Copy basic attributes
    attributes = template.attributes.except('id')
    copy = IssueTemplate.new(attributes)
    copy.template_title = "#{l(:label_copy)} #{template.template_title}"

    copy.assignable_projects = template.template_projects
    copy.assignable_secondary_projects = template.secondary_projects if Redmine::Plugin.installed?(:redmine_multiprojects_issue)

    # Copy custom_field_values
    copy.custom_field_values = template.custom_field_values.to_h { |cv| [cv.custom_field_id.to_s, cv.value] }

    # Copy sections associated with each section group by duplicating
    template.section_groups.each do |group|
      new_group = group.dup
      new_group.sections = group.sections.map { |section| section.dup }
      copy.section_groups << new_group
    end
    copy
  end
end
