module RedmineTemplates
  module IssueQueryPatch

    def self.prepended(base)
      base.class_eval do
        unloadable
        self.available_columns << QueryColumn.new(:issue_template, :sortable => "#{IssueTemplate.table_name}.template_title", :groupable => true)
      end
    end

    def initialize_available_filters
      super
      template_values = IssueTemplate.all.collect { |s| [s.template_title, s.id.to_s] }.sort_by { |v| v.first }
      add_available_filter("issue_template_id", :type => :list_subprojects, :values => template_values)
    end

    def joins_for_order_statement(order_options)
      joins = [super]
      if order_options
        if order_options.include?('issue_templates')
          joins << "LEFT OUTER JOIN #{IssueTemplate.table_name} ON #{IssueTemplate.table_name}.id = #{queried_table_name}.issue_template_id"
        end
      end
      joins.any? ? joins.join(' ') : nil
    end

  end
end

IssueQuery.prepend RedmineTemplates::IssueQueryPatch
