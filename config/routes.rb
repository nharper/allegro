Allegro::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  root 'attendance#home'

  # TODO(nharper): Most of these routes are incomplete right now
  resources :performers do
    member do
      get 'photo'
      get 'newcard'
    end
    collection do
      get 'printcards'
      get 'upload_csv'
      post 'import'
    end
  end

  resources :registrations do
    collection do
      get 'audit'
    end
  end

  # TODO(nharper): Most of these routes are incomplete right now
  resources :cards do
  end

  # TODO(nharper): Most of these routes are incomplete right now
  resources :rehearsals do
    member do
      get 'attendance'
      post 'attendance', action: 'update_attendance'
      get 'checkin'
      get 'checkin_manifest'
      post 'checkin', action: 'update_checkin'
      get 'raw_attendance'
      post 'reconcile'
    end
    collection do
      get 'all'
    end
  end

  resources :concerts, :only => [] do
    member do
      get'attendance'
    end
  end

  # TODO(nharper): Clean up all routing
  resource :attendance, :controller => 'attendance', :only => [] do
    get 'list', :action => 'list', :as => 'list'
  end

  resources :auth, :only => [] do
    # TODO(nharper): The following collection routes generate helpers like
    # 'login_auth_index_path'. Figure out how to get them to be like
    # 'login_auth_path' instead.
    collection do
      get 'login'
      get 'error'
      get 'logout'
      get 'token'
      if Rails.env.development?
        get 'dev_login'
      end
    end
    get 'finish', :on => :member
  end
end
