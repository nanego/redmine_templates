Rails.application.routes.draw do
  post "/issue_templates/init" => "issue_templates#init", :as => :init_issue_template
  post "/issue_templates/complete_form" => "issue_templates#complete_form"
  resources :issue_templates
end