Rails.application.routes.draw do
  post "/issue_templates/init" => "issue_templates#init", :as => :init_issue_template
  match 'issue_templates/update_form', :controller => 'issue_templates', :action => 'update_form', :via => [:put, :post], :as => 'issue_template_form'
  post 'issue_templates/:id/enable' => "issue_templates#enable", :as => :enable_issue_template
  match 'issue_templates/similar_templates', :controller => 'issue_templates', :via => [:put, :post], :action => 'similar_templates'

  resources :issue_templates, except: [:show] do
    collection do
      get :custom_form
    end
  end

  match "/projects/:project_id/settings/issue_templates" => "issue_templates#project_settings", :via => [:put, :patch]
end
