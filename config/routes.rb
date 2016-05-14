Rails.application.routes.draw do
  root to: "pages#welcome"

  get 'checkout/copy/:id' => 'orders#copy', as: :commission_copy_checkout
  get 'checkout/similar/:id' => 'orders#similar', as: :commission_similar_checkout
  get 'checkout/new/:id' => 'orders#new', as: :commission_new_checkout
  get 'about/contact_us' => 'pages#contact_us'
  get 'about/faq' => 'pages#faq'
  get "/dashboard" => "users#dashboard", as: :user_dashboard

  resources :friendships, only:[:create, :destroy]
  resources :message_threads, only: [:index, :show, :create, :destroy]
  resources :messages, only: [:create]
  resources :orders, except: [:edit, :update]
  resources :commissions do
    post :make_similar, on: :collection
  end
  resources :categories, except: [:edit] do
    get "/categories/:id", :action => :show, :defaults => {:page => 1, :display_size => 6}
  end

  devise_scope :user do
    get "/users/show" => "registrations#show", as: :show_user_registration
    get "/users/:id/profile" => "users#profile", as: :user_profile
    get "/activity_feed" => "users#activity_feed", as: :user_activity_feed    
    get "/listings" => "users#listings", as: :user_listings
  end

  devise_for :users, controllers: { registrations: 'registrations' }

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'commissions/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: commission.id)
  #   get 'commissions/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :commissions

  # Example resource route with options:
  #   resources :commissions do
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
  #   resources :commissions do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :commissions do
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
  #     # Directs /admin/commissions/* to Admin::CommissionsController
  #     # (app/controllers/admin/commissions_controller.rb)
  #     resources :commissions
  #   end
end
