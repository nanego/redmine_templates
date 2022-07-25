require_dependency 'issue_query'

class IssueQuery < Query
  self.available_columns << QueryColumn.new(:issue_template, :sortable => false, :default_order => 'asc')
end

module PluginRedmineTemplates
  module IssueQueryPatch

    def initialize_available_filters
      super
      template_values = IssueTemplate.all.collect { |s| [s.template_title, s.id.to_s] }.sort_by { |v| v.first }
      add_available_filter("issue_template_id", :type => :list, :values => template_values)
    end

  end
end

IssueQuery.prepend PluginRedmineTemplates::IssueQueryPatch
