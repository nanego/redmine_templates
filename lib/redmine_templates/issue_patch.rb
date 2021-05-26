require_dependency 'issue'

class Issue < ActiveRecord::Base

  def generated_subject(pattern:, sections_params: [])
    pattern.gsub(/{\w+}/) do |attribute|
      attribute = attribute.delete_prefix("{").delete_suffix("}")

      case attribute
      when /^cf_\d+/
        cf_identifier = attribute.delete_prefix("cf_")
        cf = IssueCustomField.where(id: cf_identifier).first
        self.custom_field_value(cf) if cf.present?
      when /^cf_\w+/
        cf_identifier = attribute.delete_prefix("cf_")
        cf = IssueCustomField.where("lower(name) = ? ", cf_identifier.humanize.downcase).first
        self.custom_field_value(cf) if cf.present?
      when /^section_\d+/
        section_index = attribute.delete_prefix("section_").to_i
        if sections_params.present? && sections_params[section_index].present?
          section = issue_template.descriptions[section_index]
          section.rendered_value(sections_params[section_index], textile: false, value_only: true) if section.present?
        end
      else
        self.send(attribute.to_sym) if self.respond_to?(attribute)
      end

    end

  end

end
