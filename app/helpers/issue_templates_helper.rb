module IssueTemplatesHelper

  def project_tree_options(projects, options = {})
    s = ''
    project_tree(projects) do |project, level|
      name_prefix = (level > 0 ? '&nbsp;' * 2 * level + '&#187; ' : '').html_safe
      tag_options = { :value => project.id }
      if project == options[:selected] || (options[:selected].respond_to?(:include?) && options[:selected].include?(project))
        tag_options[:selected] = 'selected'
      else
        tag_options[:selected] = nil
      end
      if options[:disabled].respond_to?(:include?) && options[:disabled].include?(project)
        tag_options[:disabled] = 'disabled'
      else
        tag_options[:disabled] = nil
      end
      tag_options.merge!(yield(project)) if block_given?
      s << content_tag('option', name_prefix + h(project), tag_options)
    end
    s.html_safe
  end

  def reorder_templates_handle(object, options = {})
    data = {
      :reorder_url => options[:url] || url_for(object),
      :reorder_param => options[:param] || object.class.name.underscore
    }
    content_tag('span', '',
                :class => "icon-only icon-sort-handle sort-handle sort-handle-#{object.class.try(:short_name)}",
                :data => data)
  end

  def reload_current_value(sections_attributes, section, repeatable_group_index = 0, get_all_attributes: false)
    if sections_attributes.present?

      section_group_id = section.issue_template_section_group.id.to_s
      repeatable_group_index = repeatable_group_index.to_s
      section_id = section.id.to_s

      if @sections_attributes[section_group_id].present?
        if @sections_attributes[section_group_id][repeatable_group_index].present?
          if @sections_attributes[section_group_id][repeatable_group_index]["sections_attributes"].present?
            if get_all_attributes
              return @sections_attributes[section_group_id][repeatable_group_index]["sections_attributes"][section_id]
            else
              return @sections_attributes[section_group_id][repeatable_group_index]["sections_attributes"][section_id]['text']
            end
          end
        end
      end
    end
    nil
  end

  def issue_template_section_form(form, section_class, template, &block)
    if template
      template_class = "template"
      template_target_name = "split-description.#{section_class.short_name}_template"
      template_style = "display:none;"
    else
      template_class = ""
      template_target_name = nil
      template_style = nil
    end

    delete_link = content_tag :span, style: "float: right;" do
      link_to("Supprimer", '#',
              class: "icon icon-del link-cursor action",
              data: { action: "description-item-form#delete" }) +
        form.hidden_field(:_destroy, :value => 0, data: { target: "description-item-form.destroy_hidden" })
    end

    if section_class.editable?
      label_expand = section_class.name == "IssueTemplateSectionGroup" ? "Afficher les sections" : "Afficher les détails"
      label_collapse = section_class.name == "IssueTemplateSectionGroup" ? "Masquer les sections" : "Masquer les détails"
      initial_state = (section_class.name != "IssueTemplateSectionGroup" || template ? "collapsed" : "")
      toggle_display_link = content_tag :span, style: "float: right;margin-right: 2em;" do
        link_to (initial_state != "collapsed" ? label_collapse : label_expand),
                '#',
                class: 'icon icon-list expand_collapse action',
                data: { action: "description-item-form#expand_collapse",
                        label_expand: label_expand,
                        label_collapse: label_collapse }
      end
    else
      toggle_display_link = ""
    end

    reorder_handle = reorder_templates_handle(form.object, :url => "#")
    # position_section_tooltip = content_tag('span', '0', :class => "position-section-tooltip")
    hidden_position_field = form.hidden_field(:position)
    if section_class.name == "IssueTemplateSectionGroup"
      hidden_type_field = ""
    else
      hidden_type_field = form.hidden_field(:type, :value => section_class.name)
    end

    content_tag :div,
                class: "split_description #{section_class.short_name} #{template_class} #{initial_state}",
                data: { controller: "description-item-form",
                        target: template_target_name },
                style: template_style do
      delete_link +
        toggle_display_link +
        # position_section_tooltip +
        reorder_handle +
        hidden_position_field +
        hidden_type_field +
        capture(&block)
    end
  end

  def link_to_issue_template(template)
    if template
      link_to "##{template.id} - #{template.template_title}", edit_issue_template_path(template)
    else
      ""
    end
  end

  def numeric_edit_tag(tag_id, tag_name, value, min, max, options = {})
    #  Calculate the minimum value (smallest integer with min digits) (10^(min-1))
    min_value = 10**(min.to_i - 1)
    #  Calculate the maximum value (largest integer with max digits) (10^max - 1)
    max_value = 10**(max.to_i) - 1
    # Generate the range field tag with specified options
    edit_tag = range_field_tag(tag_name,
                                    value,
                                    options.merge(id:tag_id,
                                                  min: min_value,
                                                  max: max_value
                                                ))

    edit_tag << content_tag(:span, value, class: "range_selected_value")
    # Add JavaScript to update the displayed value
    edit_tag << javascript_tag(
      <<~JAVASCRIPT
        $(document).on("input change", "##{tag_id}", function(e) {
          var value = $(this).val();
          $(this).next('.range_selected_value').html(value);
        })
      JAVASCRIPT
    )
    edit_tag
  end

end
