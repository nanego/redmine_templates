module RedmineTemplates
  module TrackerPatch
    def set_default_tracker_id_in_issue_templates
      IssueTemplate.where(tracker_id: id).update_all(tracker_id: 0)
    end
  end
end

class Tracker
  include RedmineTemplates::TrackerPatch

  has_many :issue_templates

  before_destroy :set_default_tracker_id_in_issue_templates
end
