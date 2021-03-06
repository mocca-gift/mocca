Rails.application.routes.draw do
  devise_for :users, :controllers => {
    sessions: 'devise/sessions',
    registrations: 'devise/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  resources :infos do
    member {get :img}
  end
  resources :calendars
  resources :gifts do
    member {get :img}
    member {get :eval}
  end
  resources :questions
  resources :anstoevals

  get '/admin' => 'welcome#admin'

  get '/qflow' => 'qflow#index'
  get '/qflow_continue' => 'qflow#continue'
  post '/result' => 'result#index'
  get '/result/countup' => 'result#countup'
  get '/result/countdown' => 'result#countdown'
  get '/result/countdown2' => 'result#countdown2'
  get '/new_arrival' => 'welcome#new'
  get '/info' => 'welcome#info'
  
  get '/calendar/getevent' => 'calendars#getevent'
  get '/calendar/search' => 'calendars#search'
  get '/calendar/ajaxcreate' => 'calendars#ajaxcreate'
  get '/calendar/daynameconf' => 'calendars#daynameconf'
  get '/calendar/nearday' => 'calendars#nearday'
  get '/calendar/search_bud' => 'calendars#search_bud'
  get '/calendar/search_flower' => 'calendars#search_flower'
  get '/calendar/eval' => 'calendars#eval'
  get '/calendar/get_calendar' => 'calendars#get_calendar'
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  
  # for Line Bot
    post 'linebot/callback' => 'webhook#callback'
  #for FB Bot
    post '/fbbot/callback' => 'fbmessenger#callback'

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
