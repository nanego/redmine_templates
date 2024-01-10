module RedmineTemplates
  module MenuManagerPatch
    def render_menu(menu, current_project = nil)

      if (current_project.present? &&
        current_project.issue_templates.present? &&
        (Issue.allowed_target_trackers(current_project) & current_project.issue_templates.map(&:tracker)).any?)
        Redmine::MenuManager.map :project_menu do |project_menu|
          current_project.issue_templates.includes(:tracker).reorder('trackers.position asc, issue_templates.template_title asc').each do |template|
            unless project_menu.find("new_issue_template_#{template.id}".to_sym)
              project_menu.push "new_issue_template_#{template.id}".to_sym,
                                new_project_issue_path(project: current_project, template_id: template.id),
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
                                      Issue.allowed_target_trackers(current_project).include?(template.tracker) &&
                                      template.template_projects.include?(current_project)
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
