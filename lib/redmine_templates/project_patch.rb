require_dependency 'project'

class Project < ActiveRecord::Base
  scope :active_by_attributes, (lambda do
    select('id, name').where(:status => STATUS_ACTIVE)
  end)
end
