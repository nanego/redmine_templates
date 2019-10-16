Deface::Override.new :virtual_path => 'issues/_form',
                     :name         => 'insert_tracker_field_with_read_only_mode',
                     :replace      => 'erb[loud]:contains("f.select :tracker_id")',
                     :partial      => "issues/tracker_field_with_read_only"
Deface::Override.new :virtual_path => 'issues/_form_with_positions',
                     :name         => 'insert_tracker_field_with_read_only_mode',
                     :replace      => 'erb[loud]:contains("f.select :tracker_id")',
                     :partial      => "issues/tracker_field_with_read_only"
