class IssueTemplatesController < ApplicationController

  helper :custom_fields
  include CustomFieldsHelper

  before_filter :find_project, only: [:init, :index, :complete_form, :edit]

  def init
    params[:issue].merge!({project_id: params[:project_id]}) if params[:issue]
    @issue_template = IssueTemplate.new(params[:issue])
    @issue_template.project = @project
    @issue_template.projects = [@project]
    @issue_template.author ||= User.current

    @priorities = IssuePriority.active
    render :new
  end

  def new
  end

  def edit
    @issue_template = IssueTemplate.find(params[:id])
    @priorities = IssuePriority.active
  end

  def create
    @issue_template = IssueTemplate.new(params[:issue_template])
    @issue_template.author ||= User.current

    if @issue_template.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_issue_template_successfully_created)
          redirect_to issue_templates_path(project_id: @issue_template.project_id)
        }
      end
    else
      @priorities = IssuePriority.active
      respond_to do |format|
        format.html { render :action => :new }
      end
    end
  end

  def update
    @issue_template = IssueTemplate.find(params[:id])

    if @issue_template.update_attributes(params[:issue_template])
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_issue_template_successfully_updated)
          redirect_to issue_templates_path(project_id: @issue_template.project_id)
        }
      end
    else
      @priorities = IssuePriority.active
      render action: :edit
    end

  end

  def index
   tracker_ids = @project.get_issue_templates.select(:tracker_id).map(&:tracker_id).uniq
   @template_map = Hash::new
   tracker_ids.each do |tracker_id|
     templates = @project.get_issue_templates.where("tracker_id = ?", tracker_id)
     if templates.any?
       @template_map[Tracker.find(tracker_id)] = templates
     end
   end
  end

  # Updates the template form when changing the project, status or tracker on template creation/update
  def update_form
    if params[:issue_template][:id]
      @issue_template = IssueTemplate.find(params[:id])
      @issue_template.assign_attributes(params[:issue_template])
    else
      @issue_template = IssueTemplate.new(params[:issue_template])
    end
    @priorities = IssuePriority.active
  end

  # Complete issue form when applying a template on a new issue
  def complete_form
    @issue_template = IssueTemplate.find(params[:id])
  end

  def destroy
    @issue_template = IssueTemplate.find(params[:id])
    @issue_template.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_issue_template_successfully_deleted)
        redirect_to(:back)
      }
    end
  end

  private

    def find_project
      begin
        @project ||= Project.find(params[:project_id])
      rescue ActiveRecord::RecordNotFound
        render_404
      end
    end

end