
Deface::Override.new :virtual_path => 'issues/_form',
                     :name         => 'insert_tracker_field_with_read_only_mode',
                     :replace      => 'p:contains("f.select :tracker_id")',
                     :original     => 'ebc338c4354575e5ba868ddd598b72bda6cea04f',
                     :partial      => "issues/tracker_field_with_read_only"
Deface::Override.new :virtual_path => 'issues/_form_with_positions',
                     :name         => 'insert_tracker_field_with_read_only_mode',
                     :replace      => 'p:contains("f.select :tracker_id")',
                     :partial      => "issues/tracker_field_with_read_only"

Deface::Override.new :virtual_path => 'issues/_form',
                     :name         => 'hide_subject_field_when_autocomplete',
                     :replace      => 'p:contains("f.text_field :subject")',
                     :partial      => "issues/subject_field"
Deface::Override.new :virtual_path => 'issues/_form_with_positions',
                     :name         => 'hide_subject_field_when_autocomplete',
                     :replace      => 'p:contains("f.text_field :subject")',
                     :partial      => "issues/subject_field"

Deface::Override.new :virtual_path      => "issues/_form",
                     :name              => "display_description_field_with_sections",
                     :replace           => "erb[silent]:contains(\"if @issue.safe_attribute? 'description' \")",
                     :original          => "0dbbe91b2f6ecf9a66aa7e994df6381f90f19219",
                     :closing_selector  => "erb[silent]:contains('end')",
                     :partial           => "issues/description_field"
Deface::Override.new :virtual_path      => "issues/_form_with_positions",
                     :name              => "display_description_field_with_sections",
                     :replace           => "erb[silent]:contains(\"if @issue.safe_attribute? 'description' \")",
                     :original          => "0dbbe91b2f6ecf9a66aa7e994df6381f90f19219",
                     :closing_selector  => "erb[silent]:contains('end')",
                     :partial           => "issues/description_field"

Deface::Override.new :virtual_path      => "issues/_form",
                     :name              => "add_sections_fields",
                     :insert_bottom     => "#attributes",
                     :original          => "0dbbe91b2f6ecf9a66aa7e994df6381f90f19219",
                     :partial           => "issues/sections_fields"
Deface::Override.new :virtual_path      => "issues/_form_with_positions",
                     :name              => "add_sections_fields",
                     :insert_bottom     => "#attributes",
                     :original          => "0dbbe91b2f6ecf9a66aa7e994df6381f90f19219",
                     :partial           => "issues/sections_fields"
Deface::Override.new :virtual_path      => "issues/_form",
                     :name              => "display_projects_only_those_where_the_template_is_active",
                     :replace           => "erb[silent]:contains(\"projects = projects_for_select(@issue) \")",
                     :original          => "0dbbe91b2f6ecf9a66aa7e994df6381f90f19219",
                     :text              => "<% projects = projects_for_select_for_issue_via_template(@issue, @issue_template) %>"
 
