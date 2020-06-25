Deface::Override.new :virtual_path => 'issues/_form',
                     :name         => 'insert_tracker_field_with_read_only_mode',
                     :replace      => 'p:contains("f.select :tracker_id")',
                     :partial      => "issues/tracker_field_with_read_only"
Deface::Override.new :virtual_path => 'issues/_form_with_positions',
                     :name         => 'insert_tracker_field_with_read_only_mode',
                     :replace      => 'p:contains("f.select :tracker_id")',
                     :partial      => "issues/tracker_field_with_read_only"

Deface::Override.new :virtual_path      => "issues/_form",
                     :name              => "remove_description_field",
                     :remove            => "erb[silent]:contains(\"if @issue.safe_attribute? 'description' \")",
                     :closing_selector  => "erb[silent]:contains('end')"

Deface::Override.new :virtual_path      => "issues/_form",
                     :name              => "add_description_field_with_sections",
                     :insert_before     => "div#attributes",
                     :partial           => "issues/description_split_form"


