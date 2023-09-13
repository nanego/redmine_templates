require_dependency "enumeration"

class Typology < Enumeration

  has_many :issue_templates, :dependent => :nullify

end
