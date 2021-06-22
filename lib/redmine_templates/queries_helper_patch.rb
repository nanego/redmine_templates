require_dependency 'projects_queries_helper'

module PluginRedmineTemplates
  module QueriesHelper

    def column_content(column, item)
      if item.is_a? Project
        case column.name
        when :issue_template_id
          issue_template_map[item.id]
        else
          super
        end
      else
        super
      end
    end

    def csv_content(column, project)
      case column.name
      when   :issue_template_id
        value = issue_template_map[project.id]
      else
        return super
      end
      
      csv_value(column, project, value) 

    end
  end
end

QueriesHelper.prepend PluginRedmineTemplates::QueriesHelper
ActionView::Base.prepend QueriesHelper
ProjectsController.prepend QueriesHelper
