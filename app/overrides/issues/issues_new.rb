# encoding: utf-8

include IssueTemplatesHelper

Deface::Override.new :virtual_path  => 'issues/new',
                     :name          => 'add-save-template-button-to-issues-new',
                     :insert_after  => 'code[erb-loud]:contains("preview_link")',
                     :text          => '<% if User.current.admin? || User.current.allowed_to?(:create_issue_templates, @project) %>
                                        <%= link_to "Enregistrer en tant que template",
                                            "#",
                                            :id => "init_issue_template",
                                            :"data-href" => init_issue_template_path(project_id: @project.id),
                                            class: "icon icon-copy pull-right" %>
                                        <% end %>'

Deface::Override.new :virtual_path  => 'issues/new',
                     :name          => 'add-template-selection-to-issues-new',
                     :insert_before  => 'h2' do
  '<% if User.current.admin? || User.current.allowed_to?(:use_issue_templates, @project) %>
    <% tracker_ids = IssueTemplate.where("project_id = ?", @project.id).pluck(:tracker_id)
      @template_map = Hash::new
      tracker_ids.each do |tracker_id|
        templates = IssueTemplate.where("project_id = ? AND tracker_id = ?", @project.id, tracker_id)
        if templates.any?
          @template_map[Tracker.find(tracker_id)] = templates
        end
      end
    %>
    <% if @template_map.size > 0 %>
      <%= form_tag issue_templates_complete_form_path, :method => :post, remote: true, :id => "form-select-issue-template" do %>
        <%= hidden_field_tag :project_id, @project.id %>
        <%= select_tag :template, grouped_templates_for_select(@template_map), :prompt=>l("choose_a_template"), :id => "select_issue_template" %>
      <% end %>
    <% end %>
  <% end %>'
end