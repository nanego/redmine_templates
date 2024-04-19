require_relative '../../helpers/issue_templates_helper'
include IssueTemplatesHelper

Deface::Override.new :virtual_path  => 'issues/show',
                     :name          => 'add-template-field',
                     :original      => '8f374ec2439b27545906aae44228462dfe14d196',
                     :insert_bottom => 'div.attributes',
                     :text          => %{
                                        <% instance_manager = Redmine::Plugin.installed?(:redmine_scn) ? User.current.try(:instance_manager?) : false %>
                                        <%= issue_fields_rows do |rows|
                                          if User.current.admin? || instance_manager
                                            rows.left l(:label_issue_template), link_to_issue_template(@issue.issue_template), :class => 'template'
                                          end
                                        end %>
                                        }
