# encoding: utf-8
require File.dirname(__FILE__) + '/../../helpers/issue_templates_helper'
include IssueTemplatesHelper

require File.dirname(__FILE__) + '/../../../lib/redmine_templates/redmine_core_patch'
Project.send(:include, PatchingProjectModel)

Deface::Override.new :virtual_path  => 'issues/new',
                     :name          => 'add-save-template-button-to-issues-new',
                     :insert_after  => 'erb[loud]:contains("preview_link")',
                     :text          => '<% if @issue.project.present? && (User.current.admin? || User.current.allowed_to?(:create_issue_templates, @issue.project)) %>
                                        <%= link_to "Enregistrer en tant que template",
                                            "#",
                                            :id => "init_issue_template",
                                            :"data-href" => init_issue_template_path(project_id: @issue.project.id),
                                            class: "icon icon-copy pull-right" %>
                                        <% end %>'

Deface::Override.new :virtual_path  => 'issues/new',
                     :name          => 'add-template-selection-to-issues-new',
                     :insert_before  => 'erb[loud]:contains("title")' do
  '<%
    tracker_ids = @issue.project.get_issue_templates.select(:tracker_id).where("template_enabled = ?", true).map(&:tracker_id).uniq
    @template_map = Hash::new
    tracker_ids.each do |tracker_id|
      if Setting["plugin_redmine_templates"]["disable_templates"]
        templates = @issue.project.get_issue_templates.where("tracker_id = ? AND template_enabled = ?", tracker_id, true)
      else
        templates = @issue.project.get_issue_templates.where("tracker_id = ?", tracker_id)
      end
      if templates.any?
        @template_map[Tracker.find(tracker_id)] = templates
      end
    end
  %>
  <% if @template_map.size > 0 %>
    <%= form_tag issue_templates_path, :id => "form-select-issue-template" do %>
      <%= hidden_field_tag :project_id, @issue.project.id %>
      <%= hidden_field_tag :track_changes, false %>
      <%= select_tag :id, grouped_templates_for_select(@template_map, @issue.project), :prompt=>l("choose_a_template"), :id => "select_issue_template" %>
    <% end %>
  <% end %>'
end

Deface::Override.new :virtual_path  => 'issues/new',
                     :name          => 'autocomplete-new-issue-from-url-template',
                     :insert_after  => '#preview',
                     :original => 'bcfa1ba4130d1a98d6dc7f126d897cfd5bda13fc' do
  '
  <%
    @issue_template = IssueTemplate.find_by_id(params[:template_id]) if params[:template_id] && (begin Integer(params[:template_id]) ; true end rescue false)
    @issue_template.increment!(:usage) if @issue_template
  %>
  <script type="text/javascript">
    <%= render(:partial => "issue_templates/load_select_js_functions", :handlers => [:erb], :formats => [:js]) %>
    <% if @issue_template %>
      <%= render(:partial => "issue_templates/load_update_functions", :handlers => [:erb], :formats => [:js]) %>
      startUpdate();
    <% end %>
  </script>
  '
end
