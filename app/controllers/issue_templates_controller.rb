class IssueTemplatesController < ApplicationController

  helper :custom_fields
  include CustomFieldsHelper

  before_filter :find_project, only: [:init, :edit]
  before_filter :find_optional_project, only: [:index, :new]

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
    @project ||= Project.where(parent_id: nil).first
    @templates = @project.get_issue_templates
  end

  # Updates the template form when changing the project, status or tracker on template creation/update
  def update_form
    unless params[:issue_template][:id].blank?
      @issue_template = IssueTemplate.find(params[:issue_template][:id])
      @issue_template.assign_attributes(params[:issue_template])
    else
      @issue_template = IssueTemplate.new(params[:issue_template])
    end
    @priorities = IssuePriority.active
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

  def enable
    @issue_template = IssueTemplate.find(params[:id])
    @issue_template.template_enabled = !@issue_template.template_enabled?
    @issue_template.save
  end

  private

    def find_project
      begin
        @project ||= Project.find(params[:project_id])
        check_if_module_is_enabled
      rescue ActiveRecord::RecordNotFound
        render_404
      end
    end

    def find_optional_project
      @project = Project.find(params[:project_id]) unless params[:project_id].blank?
    rescue ActiveRecord::RecordNotFound
      render_404
    end

  def check_if_module_is_enabled
    unless @project.module_enabled?("issue_templates")
      flash[:error] = l(:notice_issue_template_module_is_not_enabled)
      redirect_to(:back)
    end
  end

end