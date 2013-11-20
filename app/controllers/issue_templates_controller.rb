class IssueTemplatesController < ApplicationController

  before_filter :find_project, only: [:init, :index, :complete_form]

  def init
    @issue_template = IssueTemplate.new(params[:issue])
    @issue_template.project = @project
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
          redirect_to issue_templates_path(project_id: @issue_template.project.id)
        }
      end
    else
      # puts @issue_template.errors.full_messages
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
          redirect_to issue_templates_path(project_id: @issue_template.project.id)
        }
      end
    else
      @priorities = IssuePriority.active
      render action: :edit
    end

  end

  def index
   tracker_ids = IssueTemplate.where('project_id = ?', @project.id).pluck(:tracker_id)
   @template_map = Hash::new
   tracker_ids.each do |tracker_id|
     templates = IssueTemplate.where('project_id = ? AND tracker_id = ?',
                                     @project.id, tracker_id)
     if templates.any?
       @template_map[Tracker.find(tracker_id)] = templates
     end
   end
  end

  def complete_form
    @issue_template = IssueTemplate.find(params[:template])
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