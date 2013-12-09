module IssueTemplatesHelper
  def grouped_templates_for_select(grouped_options, project, selected_key = nil, prompt = nil)
    body = ''
    body << content_tag(:option, prompt, { :value => "" }, true) if prompt

    grouped_options = grouped_options.sort if grouped_options.is_a?(Hash)

    grouped_options.each do |group|
      body << content_tag(:optgroup, templates_options_for_select(group[1], project, selected_key), :label => group[0])
    end

    if User.current.admin? || User.current.allowed_to?(:create_issue_templates, project)
      body << content_tag(:option, "-----------", { :value => "", :disabled => 'disabled' }, true)
      body << content_tag(:option, l("show_templates"), { :value => issue_templates_path(project_id: project.id) }, true)
    end

    body.html_safe
  end

  def templates_options_for_select(container, project, selected = nil )
    return container if String === container

    selected, disabled = extract_selected_and_disabled(selected).map do | r |
      Array.wrap(r).map { |item| item.to_s }
    end

    container.map do |element|
      html_attributes = option_html_attributes(element)
      text = element.template_title
      value = element.id
      selected_attribute = ' selected="selected"' if option_value_selected?(value, selected)
      disabled_attribute = ' disabled="disabled"' if disabled && option_value_selected?(value, disabled)
      %(<option value="#{ERB::Util.html_escape(new_project_issue_url(project_id: project.id, template_id: value))}"#{selected_attribute}#{disabled_attribute}#{html_attributes}>#{ERB::Util.html_escape(text)}</option>)
    end.join("\n").html_safe

  end

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

end