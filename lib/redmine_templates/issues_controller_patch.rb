module RedmineTemplates
  module IssuesControllerPatch
    def self.prepended(base)
      base.prepend_before_action :set_template_as_params, :only => [:new]
      base.append_before_action :finish_template_set_up, :only => [:new]
      base.append_before_action :keep_sections_values, :only => [:new, :create]
      base.append_before_action :update_description_with_sections, :only => [:create]
      base.append_before_action :update_subject_when_autocomplete, :only => [:create]
    end

    def set_template_as_params
      if params[:template_id] && params[:template_id].to_i.to_s == params[:template_id]
        permitted_params_override = params[:issue].present? ? params.require(:issue).to_unsafe_h : {}
        @issue_template = IssueTemplate.find_by_id(params[:template_id])
        if @issue_template.present?
          params[:issue] = @issue_template.attributes.slice(*Issue.attribute_names).merge(permitted_params_override)
          params[:issue][:project_id] = params[:project_id]
        end
      end
    end

    def finish_template_set_up
      if @issue_template
        render_403 if @issue.project.issue_templates.exclude?(@issue_template)
        @issue.custom_field_values = @issue_template.custom_field_values.to_h { |cv| [cv.custom_field_id.to_s, cv.value] }
        if Redmine::Plugin.installed?(:redmine_multiprojects_issue)
          @issue.projects = @issue_template.secondary_projects
        end
        @issue.issue_template = @issue_template
        @issue_template.increment!(:usage)
      end
    end

    def set_template
      if params[:template_id] && params[:template_id].to_i.to_s == params[:template_id]
        permitted_params_override = params[:issue].present? ? params.require(:issue).to_unsafe_h : {}
        @issue_template = IssueTemplate.find_by_id(params[:template_id])
        if @issue_template.present?
          @issue.safe_attributes = @issue_template.attributes.slice(*Issue.attribute_names).merge(permitted_params_override)
          @issue.project = @project
          if Redmine::Plugin.installed?(:redmine_multiprojects_issue)
            @issue.projects = @issue_template.secondary_projects
          end
          @issue.issue_template = @issue_template
          @issue_template.increment!(:usage)
        end
      end
    end

    def keep_sections_values
      if params[:issue].present? && params[:issue][:issue_template].present? && params[:issue][:issue_template][:section_groups_attributes].present?
        @sections_attributes = params[:issue][:issue_template][:section_groups_attributes]
      end
    end

    def update_description_with_sections
      if @issue.issue_template&.split_description && params[:issue][:issue_template].present?
        issue_description = ""
        section_groups_attributes = params[:issue][:issue_template][:section_groups_attributes]

        section_groups_attributes.each do |section_group_id, section_groups_attributes|

          group = @issue.issue_template.section_groups.find(section_group_id)
          section_groups_attributes.each do |group_index, group_attributes|

            issue_description += group.rendered_value

            group_attributes["sections_attributes"].each do |section_id, section_attributes|
              section = @issue.issue_template.sections.find(section_id)
              if section.present?
                # This condition handles cases where there are buttons with icons but no default value.
                if section.select_type == "buttons_icons"
                  issue_description += section.rendered_value(section_attributes) unless section_attributes[:text] == ""
                else
                  issue_description += section.rendered_value(section_attributes)
                end
              end
            end
          end
        end
        @issue.description = @issue.substituted(issue_description, @sections_attributes)

      end
    end

    def update_subject_when_autocomplete
      issue_template = @issue.issue_template
      if issue_template.present? && issue_template.autocomplete_subject && issue_template.subject.present?
        @issue.subject = @issue.substituted(issue_template.subject, @sections_attributes)
      end
    end
  end
end
IssuesController.prepend RedmineTemplates::IssuesControllerPatch
