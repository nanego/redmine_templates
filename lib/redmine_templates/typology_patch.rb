module RedmineTemplates
  module TypologyPatch
    # Keep this module
  end
end

class Typology < Enumeration
  has_many :issue_templates, :dependent => :nullify
end
