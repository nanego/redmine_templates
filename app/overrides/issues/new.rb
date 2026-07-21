Deface::Override.new :virtual_path  => 'issues/new',
                     :name          => 'add-save-template-button-to-issues-new',
                     :insert_after  => 'erb[loud]:contains("submit_tag l(:button_create_and_continue)")',
                     :text          => '<% if @issue.project.present? && (User.current.admin? || User.current.allowed_to?(:create_issue_templates, @issue.project)) %>
                                        <%= link_to sprite_icon("copy", "Enregistrer en tant que template"),
                                            "#",
                                            id: "init_issue_template",
                                            "data-href": "/issue_templates/init?project_id=#{@issue.project_id}",
                                            class: "icon pull-right" %>
                                        <% end %>
                                        <%= f.hidden_field :issue_template_id %>
                                        <script type="text/javascript">
                                          <%= render(:partial => "issue_templates/load_select_js_functions", :handlers => [:erb], :formats => [:js]) %>
                                        </script>'

# Custom form
Deface::Override.new :virtual_path      => "issues/new",
                     :name              => "custom-form-from-templates",
                     :replace_contents  => "#all_attributes" do
  %(
    <% if @issue_template.present? && @issue_template.custom_form %>
      <%= render :partial => "issues/" + @issue_template.custom_form_path, :locals => {:f => f} %>
    <% else %>
      <% if Redmine::Plugin.installed?(:redmine_customize_core_fields) %>
        <%= render :partial => "issues/customized_form", :locals => {:f => f} %>
      <% else %>
        <%= render :partial => "issues/form", :locals => {:f => f} %>
      <% end %>
    <% end %>
  )
end

Deface::Override.new :virtual_path => 'issues/new',
                     :name         => 'change_form_title_if_tracker_read_only_mode',
                     :replace      => 'erb[loud]:contains("title l(:label_issue_new)")',
                     :partial      => "issues/form_title_with_tracker"

Deface::Override.new :virtual_path => 'issues/new',
                     :name         => 'hide_attachment_form_if_template_say_so',
                     :replace      => 'p#attachments_form',
                     :partial      => "issues/attachments_form"

Deface::Override.new :virtual_path  => 'issues/new',
                     :name          => 'add_script_to_hide_and_show_sections',
                     :insert_before => 'erb[silent]:contains("header_tags")',
                     :partial       => "issues/hide_and_show_sections_script"
