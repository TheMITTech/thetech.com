Rails.application.routes.draw do
  # Frontend routes
  # Homepage
  root 'frontend#homepage'

  # Article
  get '/:year/:month/:day/:slug' => 'frontend#article', as: 'frontend_article', constraints: {
    year: /\d{4}/,
    month: /\d{2}/,
    day: /\d{2}/
  }

  # Image
  get '/photos/:id' => 'frontend#image', as: 'frontend_image'

  # Section
  get '/:slug(/page/:page)' => 'frontend#section', as: 'frontend_section', constraints: {
    slug: /(news|world-and-nation|opinion|arts|sports|campus-life|fun)/
  }

  # Author
  get '/authors/:slug' => 'frontend#author', as: 'frontend_author'

  # Photographer
  get '/photographers/:slug' => 'frontend#photographer', as: 'frontend_photographer'

  # Tag
  get '/tags/:slug(/:page)' => 'frontend#tag', as: 'frontend_tag'

  # Issue index and issue
  get '/issues' => 'frontend#issue_index', as: 'frontend_issue_index'
  get '/issues/(:volume)/(:number)' => 'frontend#issue', as: 'frontend_issue', constraints: {
    volume: /\d+/,
    number: /\d+/
  }

  # Ads manifest and relay
  get '/niceties/manifest' => 'frontend#ads_manifest', as: 'frontend_ads_manifest'
  get '/niceties/:id' => 'frontend#ads_relay', constraints: {id: /\d+/}, as: 'frontend_ads_relay'

  # RSS feed
  get '/feed' => 'frontend#feed', as: 'frontend_feed', defaults: {format: 'rss'}

  get '/:section_name/:id(/:slug)', controller: 'frontend_pieces', action: 'show_old_url', constraints: {id: /\d+/, section_name: /(news|world-and-nation|opinion|arts|sports|campus-life|fun)/}

  get '/search(/:query)(/page/:page)', controller: 'frontend_pieces', action: 'search', as: 'frontend_search', constraints: {query: /.*?(?=\/)*/}
  get '/image_search(/:query)(/page/:page)', controller: 'frontend_pieces', action: 'image_search', as: 'frontend_image_search', constraints: {query: /.*?(?=\/)*/}

  get '/:volume/:number/:archivetag', controller: 'legacy_redirect', action: 'show_piece', constraints: {volume: /V\d+/, number: /N\d+/, archivetag: /[^\/]*\.html/}
  get '/:volume/:number/:parent/:archivetag', controller: 'legacy_redirect', action: 'show_piece', constraints: {volume: /V\d+/, number: /N\d+/, parent: /.*/, archivetag: /.*\.html/}

  namespace :api do
    get 'issue_lookup/:volume/:issue', action: 'issue_lookup'
    get 'article_as_xml/:id', action: 'article_as_xml'
    get 'newest_issue'
    get 'article_parts'
    get 'style_mapping'
  end

  scope '/admin' do
    get '/', to: 'static_pages#admin_homepage', as: :admin_root

    resources :ads

    resources :homepages, only: [:index, :show, :update] do
      member do
        post 'mark_publish_ready'
        post 'duplicate'
        post 'publish'
      end

      collection do
        get 'new_submodule_form'
        get 'new_row_form'
        post 'new_specific_submodule_form'
        post 'create_specific_submodule'
        post 'create_new_row'
      end
    end

    resources :issues, only: [:index, :show, :create] do
      member do
        get 'upload_pdf_form'
        post 'upload_pdf'
        delete 'remove_pdf'
      end
    end

    resources :authors, only: [:new, :create, :edit, :update, :show, :index]

    resources :sections, only: [:new, :create, :edit, :update, :show, :index]

    resources :images, only: [:new, :create, :edit, :update, :destroy, :show, :index] do
      member do
        post 'publish'
      end
    end

    resources :articles, only: [:index, :new, :create, :edit, :update, :destroy] do
      resources :drafts, only: [:index, :show, :update] do
        member do
          get 'revert'
          post 'publish'
          get 'below_fold_preview'
        end
      end

      member do
        patch 'update_rank'
      end

      collection do
        get 'below_fold_preview', controller: 'article_versions', action: 'below_fold_preview'
      end
    end

    devise_for :users, controllers: {
      registrations: 'users/registrations'
    }
    resources :users, only: [:index, :show, :edit, :update]

    get '/publish', controller: 'publishing', action: 'dashboard', as: 'publishing_dashboard'
    post '/publish', controller: 'publishing', action: 'publish'
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  get '/ads/adinfo', controller: 'frontend_static_pages', action: 'adinfo'
  get '/:name', controller: 'frontend_static_pages', action: 'show', as: 'frontend_static_page', constraints: {name: /(ads(\/(index|schedule|policies|payment|adscontact))?)|(about(\/(index|contact|opinion_policy|comments|unpublish|copyright|publication_schedule|subscribe|special_projects|donate|join|staff))?)/}
  get '/ads/adinfo/:advertiser_type', controller: 'frontend_static_pages', action: 'adinfo',
    as: 'frontend_adinfo', constraints: {advertiser_type: /[^.]*/}
  # get '/:name', controller: 'frontend_static_pages', action: 'show', as: 'frontend_static_page', constraints: {name: /[^.]*/}


  #Sitemap routes
  # get '/google_search_sitemap.xml.gz', as: :sitemap
  # get '/google_news_sitemap.xml.gz', as: :sitemap

  post '/update_mast', controller: 'frontend_static_pages', action: 'update_mast'
    # match '/testing' => 'frontend_static_pages#update_mast', via: :post

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
