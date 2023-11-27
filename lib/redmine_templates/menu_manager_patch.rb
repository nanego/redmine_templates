module RedmineTemplates
  module MenuManagerPatch
    def render_menu(menu, project = nil)

      if project.present? &&
        project.issue_templates.present? &&
        (Issue.allowed_target_trackers(project) & project.issue_templates.map(&:tracker)).any?
        Redmine::MenuManager.map :project_menu do |project_menu|
          project.issue_templates.includes(:tracker).reorder('trackers.position asc, issue_templates.template_title asc').each do |template|
            unless project_menu.find("new_issue_template_#{template.id}".to_sym)
              project_menu.push "new_issue_template_#{template.id}".to_sym,
                                { :controller => 'issues', :action => 'new', :template_id => template.id },
                                :param => :project_id,
                                :caption => Proc.new {
                                  template.reload unless template.has_been_deleted?
                                  template.title_with_tracker
                                },
                                :html => { :accesskey => Redmine::AccessKeys.key_for(:new_issue) },
                                :if => Proc.new { |project|
                                  if template.has_been_deleted?
                                    false
                                  else
                                    template.reload
                                    template.template_enabled &&
                                      Issue.allowed_target_trackers(project).include?(template.tracker) &&
                                      template.template_projects.include?(project)
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
