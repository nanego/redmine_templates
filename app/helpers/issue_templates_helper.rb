module IssueTemplatesHelper

  def project_tree_options(projects, options = {})
    s = ''
    project_tree(projects) do |project, level|
      name_prefix = (level > 0 ? '&nbsp;' * 2 * level + '&#187; ' : '').html_safe
      tag_options = {:value => project.id}
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
                :class => "icon-only icon-sort-handle sort-handle",
                :data => data)
  end

  def reload_current_value(sections_attributes, current_position)
    if sections_attributes.present?
      index = current_position - 1
      if @sections_attributes[index].present?
        return @sections_attributes[index]['text']
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
      template_class = "collapsed"
      template_target_name = nil
      template_style = nil
    end

    delete_link = content_tag :span, style: "float: right;" do
      link_to("Supprimer", '#',
              class: "icon icon-del link-cursor action",
              data: {action: "description-item-form#delete"}) +
          form.hidden_field(:_destroy, :value => 0, data: {target: "description-item-form.destroy_hidden"})
    end

    if section_class.editable?
      toggle_display_link = content_tag :span, style: "float: right;margin-right: 2em;" do
        link_to (template ? "Masquer les détails" : "Afficher les détails"),
                '#',
                class: 'icon icon-list expand_collapse action',
                data: {action: "description-item-form#expand_collapse"}
      end
    else
      toggle_display_link = ""
    end

    reorder_handle = reorder_templates_handle(form.object, :url => "#")
    hidden_position_field = form.hidden_field(:position)
    hidden_type_field = form.hidden_field :type, :value => section_class.name

    content_tag :div,
                class: "split_description #{section_class.short_name} #{template_class}",
                data: {controller: "description-item-form",
                       target: template_target_name},
                style: template_style do
      delete_link +
          toggle_display_link +
          reorder_handle +
          hidden_position_field +
          hidden_type_field +
          capture(&block)
    end
  end

end
