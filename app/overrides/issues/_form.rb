Deface::Override.new :virtual_path => 'issues/_form',
                     :name         => 'insert_tracker_field_with_read_only_mode',
                     :replace      => 'p:contains("f.select :tracker_id")',
                     :original     => 'ebc338c4354575e5ba868ddd598b72bda6cea04f',
                     :partial      => "issues/tracker_field_with_read_only"
Deface::Override.new :virtual_path => 'issues/_form_with_positions',
                     :name         => 'insert_tracker_field_with_read_only_mode',
                     :replace      => 'p:contains("f.select :tracker_id")',
                     :partial      => "issues/tracker_field_with_read_only"

Deface::Override.new :virtual_path      => "issues/_form",
                     :name              => "remove_description_field",
                     :remove            => "erb[silent]:contains(\"if @issue.safe_attribute? 'description' \")",
                     :original          => "0dbbe91b2f6ecf9a66aa7e994df6381f90f19219",
                     :closing_selector  => "erb[silent]:contains('end')"

Deface::Override.new :virtual_path      => "issues/_form",
                     :name              => "add_description_field_with_sections",
                     :insert_before     => "div#attributes",
                     :original          => "e82da8a57ee682e41ee7df667681b7defb32a993",
                     :partial           => "issues/description_split_form"


