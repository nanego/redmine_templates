# encoding: utf-8
require File.dirname(__FILE__) + '/../../helpers/issue_templates_helper'
include IssueTemplatesHelper

require File.dirname(__FILE__) + '/../../../lib/redmine_templates/redmine_core_patch'
Project.send(:include, PatchingProjectModel)

Deface::Override.new :virtual_path  => 'issues/new',
                     :name          => 'add-save-template-button-to-issues-new',
                     :insert_after  => 'code[erb-loud]:contains("preview_link")',
                     :text          => '<% if @project.module_enabled?("issue_templates") && (User.current.admin? || User.current.allowed_to?(:create_issue_templates, @project)) %>
                                        <%= link_to "Enregistrer en tant que template",
                                            "#",
                                            :id => "init_issue_template",
                                            :"data-href" => init_issue_template_path(project_id: @project.id),
                                            class: "icon icon-copy pull-right" %>
                                        <% end %>'

Deface::Override.new :virtual_path  => 'issues/new',
                     :name          => 'add-template-selection-to-issues-new',
                     :original => '73b386964fd80827b5bedf659dd2048791f20713',
                     :insert_before  => 'h2' do
  '<%
    tracker_ids = @project.get_issue_templates.select(:tracker_id).map(&:tracker_id).uniq
    @template_map = Hash::new
    tracker_ids.each do |tracker_id|
      templates = @project.get_issue_templates.where("tracker_id = ?", tracker_id)
      if templates.any?
        @template_map[Tracker.find(tracker_id)] = templates
      end
    end
  %>
  <% if @project.module_enabled?("issue_templates") && @template_map.size > 0 %>
    <%= form_tag issue_templates_path, :id => "form-select-issue-template" do %>
      <%= hidden_field_tag :project_id, @project.id %>
      <%= hidden_field_tag :track_changes, false %>
      <%= select_tag :id, grouped_templates_for_select(@template_map, @project), :prompt=>l("choose_a_template"), :id => "select_issue_template" %>
    <% end %>
  <% end %>'
end

Deface::Override.new :virtual_path  => 'issues/new',
                     :name          => 'autocomplete-new-issue-from-url-template',
                     :insert_after  => '#preview' do
  '
  <%
    @issue_template = IssueTemplate.find_by_id(params[:template_id]) if params[:template_id] && (begin Integer(params[:template_id]) ; true end rescue false)
  %>
  <script type="text/javascript">
    <%= render(:partial => "issue_templates/load_select_js_functions.js.erb") %>
    <% if @issue_template %>
      <%= render(:partial => "issue_templates/load_update_functions.js.erb") %>
      startUpdate();
    <% end %>
  </script>
  '
end
