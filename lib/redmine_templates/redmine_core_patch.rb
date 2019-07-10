#for some reasons this directory isn't added in the path when we need it
require_dependency File.expand_path('../../../app/models/issue_template', __FILE__)

class Project
  has_and_belongs_to_many :issue_templates
end
