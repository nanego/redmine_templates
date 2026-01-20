module RedmineTemplates
  module MenuManagerPatch
    def render_menu(menu, current_project = nil)

      if current_project.present? &&
         current_project.issue_templates.present?
        Redmine::MenuManager.map :project_menu do |project_menu|
          templates = current_project.issue_templates
                                     .includes(:tracker)
                                     .reorder('trackers.position asc, issue_templates.template_title asc')

          templates.each do |template|
            menu_item_name = "new_issue_template_#{template.id}".to_sym
            unless project_menu.find(menu_item_name)
              template_id = template.id

              project_menu.push menu_item_name,
                                { :controller => 'issues', :action => 'new', :template_id => template_id },
                                :param => :project_id,
                                :caption => Proc.new {
                                  t = IssueTemplate.find_by(id: template_id)
                                  t&.title_with_tracker
                                },
                                :html => { :accesskey => Redmine::AccessKeys.key_for(:new_issue) },
                                :if => Proc.new { |current_project|
                                  IssueTemplateProject.exists?(
                                    issue_template_id: template_id,
                                    project_id: current_project.id
                                  ) &&
                                    IssueTemplate.where(id: template_id, template_enabled: true)
                                                 .joins(:tracker)
                                                 .where(trackers: { id: current_project.tracker_ids })
                                                 .exists?
                                },
                                :permission => :add_issues,
                                :parent => :new_issue
            end
          end
        end
      end

      super

    end
  end
end

Redmine::MenuManager::MenuHelper.prepend RedmineTemplates::MenuManagerPatch
include Redmine::MenuManager::MenuHelper
