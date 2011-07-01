FcsvrWeb::Application.routes.draw do
  root :to => 'fcsvr_cmd_histories#index'
  
  match ':controller(/:action(/:type(/:id(.:format))))'

  resources :fcsvr_cmd_histories, :only => [:index]
  match '/getmd/search(.:format)' => 'getmd#search'
  match '/entity/search(.:format)' => 'entity#search'
  match '/search(/:type(.:format))' => 'entity#search'
  match '/asset/get_rep_links(/:id(.:format))' => 'entity#get_asset_reps'
  match '/project/get_tree(/:id(.:format))' => 'entity#get_project_tree'
  match '/asset/create(.:format)' => 'entity#create'
  match '/asset/create_with_rep_links(.:format)' => 'entity#create_with_rep_links'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
