Rails.application.routes.draw do
  get 'about/about_us' => 'static_pages_controller#about'

  get 'about/contact_us' => 'static_pages_controller#contact_us'

  get 'about/faq' => 'static_pages_controller#faq'

  resources :messages
  root to: "static_pages_controller#welcome"

  get "/dashboard" => "users#dashboard", as: :user_dashboard

  resources :orders, except: [:edit, :update]
  resources :products
  resources :categories

  devise_scope :user do
    get "/users/show" => "registrations#show", as: :show_user_registration
    get "/users/:id/profile" => "users#profile", as: :user_profile
  end

  devise_for :users, controllers: { registrations: 'registrations' }

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
end
