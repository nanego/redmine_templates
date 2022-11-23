module PluginRedmineTemplates
  module UserPatch
    def remove_references_before_destroy
      super
      substitute = User.anonymous
      IssueTemplate.where(['assigned_to_id = ?', id]).update_all('assigned_to_id = NULL')
      IssueTemplate.where(['author_id = ?', id]).update_all(['author_id = ?', substitute.id])
    end
  end
end

User.prepend PluginRedmineTemplates::UserPatch