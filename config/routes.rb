Rails.application.routes.draw do

  post "/issue_templates/init" => "issue_templates#init", :as => :init_issue_template
  post "/issue_templates/complete_form" => "issue_templates#complete_form"
  match 'issue_templates/update_form', :controller => 'issue_templates', :action => 'update_form', :via => [:put, :post], :as => 'issue_template_form'

  resources :issue_templates, except: [:show]

end