require_dependency 'issue'

class Issue < ActiveRecord::Base

  # Subtitute variables with values
  def substituted(text, sections_params = [])
    text.gsub(/{[[:word:]]*}/) do |attribute|
      attribute = attribute.delete_prefix("{").delete_suffix("}")
      case attribute
      when /^cf_\d+/
        custom_field_value_by_id(attribute.delete_prefix("cf_"))
      when /^cf_[[:word:]]*/
        custom_field_value_by_name(attribute.delete_prefix("cf_"))
      when /^section_\d+/
        section_value_by_id(attribute.delete_prefix("section_"), sections_params)
      else
        self.send(attribute.downcase.to_sym) if self.respond_to?(attribute.downcase.to_sym)
      end
    end
  end

  def custom_field_value_by_id(cf_id)
    cf = IssueCustomField.where(id: cf_id).first
    cf.present? ? self.custom_field_value(cf) : ""
  end

  def custom_field_value_by_name(cf_name)
    cf = IssueCustomField.where("lower(name) = ? ", cf_name.humanize.downcase).first
    cf.present? ? self.custom_field_value(cf) : ""
  end

  def section_value_by_id(section_id, sections_params)
    section_index = section_id.to_i
    if sections_params.present? && sections_params[section_index].present?
      section = issue_template.descriptions[section_index]
      section.rendered_value(sections_params[section_index], textile: false, value_only: true) if section.present?
    else
      ""
    end
  end

end
