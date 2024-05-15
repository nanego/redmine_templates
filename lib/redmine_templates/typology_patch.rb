module RedmineTemplates
  module TypologyPatch
    # Keep this module
  end
end

if Redmine::Plugin.installed?(:redmine_typologies)
  class Typology < Enumeration
    has_many :issue_templates, :dependent => :nullify
  end
end
