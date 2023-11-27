module RedmineTemplates::IssueCategoryPatch

  def self.prepended(base)
    base.has_many :issue_templates, :class_name => 'IssueTemplate', :foreign_key => 'category_id', :dependent => :nullify
  end

end
IssueCategory.prepend RedmineTemplates::IssueCategoryPatch
