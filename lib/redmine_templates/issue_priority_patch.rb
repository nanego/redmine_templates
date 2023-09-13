require_dependency 'issue_priority'

class IssuePriority < Enumeration
  has_many :issue_templates, :foreign_key => 'priority_id'
end

module PluginRedmineTemplates
  module IssuePriorityPatch
    def objects_count
      count = super
      count + issue_templates.count
    end

    def transfer_relations(to)
      super
      issue_templates.update_all(priority_id: to.id)
    end

  end
end

IssuePriority.prepend PluginRedmineTemplates::IssuePriorityPatch
