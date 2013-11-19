module IssueTemplatesHelper
  def grouped_templates_for_select(grouped_options, selected_key = nil, prompt = nil)
    body = ''
    body << content_tag(:option, prompt, { :value => "" }, true) if prompt

    grouped_options = grouped_options.sort if grouped_options.is_a?(Hash)

    grouped_options.each do |group|
      body << content_tag(:optgroup, templates_options_for_select(group[1], selected_key), :label => group[0])
    end

    body.html_safe
  end

  def templates_options_for_select(container, selected = nil)
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
      %(<option value="#{ERB::Util.html_escape(value)}"#{selected_attribute}#{disabled_attribute}#{html_attributes}>#{ERB::Util.html_escape(text)}</option>)
    end.join("\n").html_safe

  end
end