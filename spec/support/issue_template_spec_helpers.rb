require "spec_helper"

def issues_in_list
  ids = css_select('tr.issue td.id').map(&:text).map(&:to_i)
  Issue.where(:id => ids).sort_by { |issue| ids.index(issue.id) }
end

def create_issues_from_templates
  3.times do |i|
    Issue.create(:project_id => 1, :tracker_id => 1, :author_id => 1,
                 :status_id => 1, :priority => IssuePriority.first,
                 :subject => "Issue test#{i}",
                 :issue_template_id => i + 1)
  end
end

def find_issues_with_query(query)
  Issue.where(query.statement).all
end
