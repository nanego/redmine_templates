require_relative '../../helpers/issue_templates_helper'
include IssueTemplatesHelper

Deface::Override.new :virtual_path  => 'issues/show',
                     :name          => 'add-template-field',
                     :original      => '8f374ec2439b27545906aae44228462dfe14d196',
                     :insert_bottom => 'div.attributes',
                     :text          => %{
                                        <%= issue_fields_rows do |rows|
                                          if User.current.admin?
                                            rows.left l(:label_issue_template), link_to_issue_template(@issue.issue_template), :class => 'template'
                                          end
                                        end %>
                                        }
Deface::Override.new :virtual_path  => 'issues/show',
                      :name          => 'show-issue-template-section-instruction',
                      :insert_bottom => 'div.description',
                      :text          => %{
                                          <% @issue.issue_template.section_groups.each do |group| %>
                                            <%  group.sections.each do |section| %>
                                              <% # section.show_toolbar means that Show in the generated issue %>
                                              <% if section.type == "IssueTemplateSectionInstruction" && section.show_toolbar %>
                                                <div style="height: 90px;margin-bottom: 50px;margin-top: 50px;">
                                                  <div class="instruction instruction-<%= section.instruction_type %>" style="height: 100%;padding-left: 50px;padding-top: 20px;">
                                                    <%= textilizable section.text %>
                                                  </div>
                                                </div>
                                              <% end %>
                                            <% end %>
                                          <% end %>
                                          }
