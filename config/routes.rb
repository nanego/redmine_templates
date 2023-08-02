Rails.application.routes.draw do
  post "/issue_templates/init" => "issue_templates#init", :as => :init_issue_template
  match 'issue_templates/update_form', :controller => 'issue_templates', :action => 'update_form', :via => [:put, :post], :as => 'issue_template_form'
  post 'issue_templates/:id/enable' => "issue_templates#enable", :as => :enable_issue_template
  match 'issue_templates/similar_templates', :controller => 'issue_templates', :via => [:put, :post], :action => 'similar_templates'
  post "issue_templates/add_repeatable_group" => "issue_templates#add_repeatable_group", :as => :add_repeatable_group  
  match 'issue_templates/render_select_projects_modal_by_ajax', :controller => 'issue_templates', :action => 'render_select_projects_modal_by_ajax', :via => :post,  :as => 'render_select_projects_modal_by_ajax'
  
  resources :issue_templates, except: [:show] do
    collection do
      get :custom_form
    end
  end
end
