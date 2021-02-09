namespace :redmine do
  namespace :templates do

    desc "Update sections multi-value separator"
    task :update_separator => [:environment] do

      IssueTemplateDescriptionSelect.find_each do |section|
        section.update_column(:text, section.text.gsub(',', ';'))
      end

    end

  end
end
