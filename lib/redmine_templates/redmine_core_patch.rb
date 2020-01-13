#for some reasons this directory isn't added in the path when we need it
require_dependency File.expand_path('../../../app/models/issue_template', __FILE__)

require_dependency 'project'
class Project
  has_and_belongs_to_many :issue_templates
end

require_dependency 'issue'
class Issue
  belongs_to :issue_template, optional: true
  safe_attributes 'issue_template_id'
end
