Deface::Override.new :virtual_path => 'issues/new',
                     :name         => 'change_form_title_if_tracker_read_only_mode',
                     :replace      => 'erb[loud]:contains("title l(:label_issue_new)")',
                     :original     => '5d85863faf17e3c7aab5c9856e09bdd3280a7b26',
                     :partial      => "issues/form_title_with_tracker"

Deface::Override.new :virtual_path => 'issues/new',
                     :name         => 'hide_attachment_form_if_template_say_so',
                     :replace      => 'p#attachments_form',
                     :partial      => "issues/attachments_form"
