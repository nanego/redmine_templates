Deface::Override.new :virtual_path => 'issues/new',
                     :name         => 'change_form_title_if_tracker_read_only_mode',
                     :replace      => 'erb[loud]:contains("title l(:label_issue_new)")',
                     :partial      => "issues/form_title_with_tracker"
