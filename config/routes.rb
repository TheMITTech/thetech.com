Rails.application.routes.draw do

  get '/:year/:month/:day/:slug', controller: 'frontend_pieces', action: 'show', as: 'frontend_piece', constraints: {year: /\d{4}/, month: /\d{2}/, day: /\d{2}/}

  get '/:volume/:number/:archivetag', controller: 'legacy_redirect', action: 'show_piece', constraints: {volume: /V\d+/, number: /N\d+/, archivetag: /[^\/]*\.html/}
  get '/:volume/:number/:parent/:archivetag', controller: 'legacy_redirect', action: 'show_piece', constraints: {volume: /V\d+/, number: /N\d+/, parent: /.*/, archivetag: /.*\.html/}

  resource :api, controller: 'api' do
    get 'issue_lookup/:volume/:issue', action: 'issue_lookup'
    get 'article_as_xml/:id', action: 'article_as_xml'
    get 'newest_issue'
  end

  scope '/admin' do
    resources :issues do
      member do
        get 'upload_pdf_form'
        post 'upload_pdf'
        delete 'remove_pdf'
      end
    end

    resources :authors

    resources :sections

    resources :series

    resources :pieces

    resources :images do
      resources :pictures, only: [:create, :destroy] do
        member do
          get 'direct'
        end
      end

      member do
        # I seriously doubt whether 'unassign' is a proper English word. But whatever..
        post 'unassign_piece'
        post 'assign_piece'
      end
    end

    resources :articles, only: [:index, :new, :create, :edit, :update, :destroy] do
      resources :article_versions, only: [:index, :show] do
        member do
          get 'revert'
          post 'publish'
          post 'mark_print_ready'
        end
      end

      member do
        get 'assets_list'
      end
    end

    devise_for :users, controllers: {
      registrations: 'users/registrations'
    }
    resources :users, only: [:index, :show, :edit, :update]
  end

  get 'homepage/homepage'


  get 'index_controller/index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'homepage#homepage'

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
