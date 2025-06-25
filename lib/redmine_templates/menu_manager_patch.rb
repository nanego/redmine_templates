module RedmineTemplates
  module MenuManagerPatch
    def render_menu(menu, current_project = nil)

      if current_project.present? &&
         current_project.issue_templates.present?
        Redmine::MenuManager.map :project_menu do |project_menu|
          current_project.issue_templates.includes(:tracker).reorder('trackers.position asc, issue_templates.template_title asc').each do |template|
            menu_item_name = "new_issue_template_#{template.id}".to_sym
            unless project_menu.find(menu_item_name)
              project_menu.push menu_item_name,
                                { :controller => 'issues', :action => 'new', :template_id => template.id },
                                :param => :project_id,
                                :caption => Proc.new {
                                  template.reload unless template.has_been_deleted?
                                  template.title_with_tracker
                                },
                                :html => { :accesskey => Redmine::AccessKeys.key_for(:new_issue) },
                                :if => Proc.new { |current_project|
                                  if template.has_been_deleted?
                                    false
                                  else
                                    template.reload
                                    template.template_enabled &&
                                      template.template_projects.include?(current_project) &&
                                      template.tracker_is_valid?(current_project)
                                  end
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
