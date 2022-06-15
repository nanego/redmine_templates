# encoding: utf-8
require File.dirname(__FILE__) + '/../../helpers/issue_templates_helper'
include IssueTemplatesHelper

require File.dirname(__FILE__) + '/../../../lib/redmine_templates/redmine_core_patch'

Deface::Override.new :virtual_path  => 'issues/new',
                     :name          => 'add-save-template-button-to-issues-new',
                     :insert_after  => 'erb[loud]:contains("submit_tag l(:button_create_and_continue)")',
                     :original      => '4e67d6689fbd2c21613ffb301a5e8c92ff214b5c',
                     :text          => '<% if @issue.project.present? && (User.current.admin? || User.current.allowed_to?(:create_issue_templates, @issue.project)) %>
                                        <%= link_to "Enregistrer en tant que template",
                                            "#",
                                            id: "init_issue_template",
                                            "data-href": init_issue_template_path(project_id: @issue.project.id),
                                            class: "icon icon-copy pull-right" %>
                                        <% end %>
                                        <%= f.hidden_field :issue_template_id %>
                                        <script type="text/javascript">
                                          <%= render(:partial => "issue_templates/load_select_js_functions", :handlers => [:erb], :formats => [:js]) %>
                                        </script>'

# Custom form
Deface::Override.new :virtual_path      => "issues/new",
                     :name              => "custom-form-from-templates",
                     :original => '1468c4be09f0521e1854cace7f8d7b444eb32074',
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
