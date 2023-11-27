module RedmineTemplates
  module ProjectQueryPatch

    def self.prepended(base)
      base.class_eval do
        available_columns << QueryColumn.new(:issue_template_id, :sortable => false, :default_order => 'asc')
      end
    end

    def initialize_available_filters
      super
      template_values = IssueTemplate.all.collect { |s| [s.template_title, s.id.to_s] }.sort_by { |v| v.first }
      add_available_filter("issue_templates", :type => :list_subprojects, :values => template_values)
    end

    def sql_for_issue_templates_field(field, operator, value)
      case operator
      when "!*", "*"
        issue_template_project_table = IssueTemplateProject.table_name
        project_table = Project.table_name
        # return only the projects for which a particular template or template group is activated
        "#{project_table}.id  #{ operator == '*' ? 'IN' : 'NOT IN' } (SELECT #{issue_template_project_table}.project_id FROM #{issue_template_project_table} " +
          "JOIN #{project_table} ON #{issue_template_project_table}.project_id = #{project_table}.id " + ') '
      when "=", "!"
        issue_template_project_table = IssueTemplateProject.table_name
        project_table = Project.table_name
        # return only the projects for which a particular template or template group is activated
        "#{project_table}.id #{ operator == '=' ? 'IN' : 'NOT IN' } (SELECT #{issue_template_project_table}.project_id FROM #{issue_template_project_table} " +
          "JOIN #{project_table} ON #{issue_template_project_table}.project_id = #{project_table}.id AND " +
          sql_for_field(field, '=', value, issue_template_project_table, 'issue_template_id') + ') '
      end
    end

  end
end

ProjectQuery.prepend RedmineTemplates::ProjectQueryPatch
