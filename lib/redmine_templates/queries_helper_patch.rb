module RedmineTemplates
  module QueriesHelperPatch

    def column_content(column, item)
      if item.is_a? Project
        case column.name
        when :issue_template_id
          if issue_template_map[item.id].present?
            issue_template_map[item.id].map(&:template_title).compact.join(', ')
          end
        else
          super
        end
      else
        super
      end
    end

    def csv_content(column, item)
      if item.is_a? Project
        case column.name
        when :issue_template_id
          value = issue_template_map[item.id].present? ? issue_template_map[item.id].map(&:template_title).compact.join(', ') : ''
        else
          return super
        end
        csv_value(column, item, value)
      else
        super
      end
    end
  end
end

QueriesHelper.prepend RedmineTemplates::QueriesHelperPatch
ActionView::Base.prepend QueriesHelper
ProjectsController.prepend QueriesHelper
