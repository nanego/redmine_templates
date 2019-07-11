module Redmine
  module MenuManager
    module MenuHelper
      def render_menu(menu, project = nil)

        ### START PATCH
        if project.present? && project.issue_templates.present?
          Redmine::MenuManager.map :project_menu do |project_menu|
            project.issue_templates.includes(:tracker).order('trackers.position desc, issue_templates.template_title desc').each do |template|
              puts "project_menu.find(:new_issue_template_#{template.id}) : #{project_menu.find("new_issue_template_#{template.id}".to_sym).inspect}"
              unless project_menu.find("new_issue_template_#{template.id}".to_sym)
                project_menu.push "new_issue_template_#{template.id}".to_sym,
                                  { :controller => 'issues', :action => 'new', :template_id => template.id },
                                  :param => :project_id,
                                  :caption => Proc.new {|p| template.reload; "[#{template.tracker}] #{template.template_title}" },
                                  :html => {:accesskey => Redmine::AccessKeys.key_for(:new_issue)},
                                  :if => Proc.new {|p| Issue.allowed_target_trackers(p).any? &&
                                      template.projects.include?(p)},
                                  :permission => :add_issues,
                                  :parent => :new_issue,
                                  :first => true
              end
            end
          end
        end
        ### END PATCH

        links = []
        menu_items_for(menu, project) do |node|
          links << render_menu_node(node, project)
        end
        links.empty? ? nil : content_tag('ul', links.join.html_safe)
      end
    end
  end
end
