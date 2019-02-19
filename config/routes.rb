Rails.application.routes.draw do

  ##############################################################################
  # Frontend routes
  ##############################################################################

  # Homepage
  root 'frontend#homepage'

  # Article
  get '/:year/:month/:day/:slug' => 'frontend#article', as: 'frontend_article', action: 'show', constraints: {
    year: /\d{4}/,
    month: /\d{2}/,
    day: /\d{2}/
  }

  # Image
  get '/photos/:id' => 'frontend#image', as: 'frontend_image', action: 'show'

  # Section
  get '/:slug(/page/:page)' => 'frontend#section', as: 'frontend_section', constraints: {
    slug: /(news|world-and-nation|opinion|arts|sports|campus-life|fun|science)/
  }

  # Author
  get '/authors/:slug' => 'frontend#author', as: 'frontend_author'

  # Photo
  get '/photographers/:slug' => 'frontend#photographer', as: 'frontend_photographer'
  # Photo submission link temporary redirect
  get '/submitphoto', to: redirect('https://www.dropbox.com/request/DRmRaJGEr7LfVXUG2FHf', status: 302)
  # Caption submission link temporary redirect
  get '/submitcaption', to: redirect('https://docs.google.com/spreadsheets/d/1aoRyGfaOIK9WIMaktEO9G_LAyBKHs8VCPnMBVVhtyDs/edit?usp=sharing', status: 302)

  # Tag
  get '/tags/:slug(/:page)' => 'frontend#tag', as: 'frontend_tag'

  # Issue index and issue
  get '/issues' => 'frontend#issue_index', as: 'frontend_issue_index'
  get '/issues/(:volume)/(:number)' => 'frontend#issue', as: 'frontend_issue', constraints: {
    volume: /\d+/,
    number: /\d+/
  }
  get '/issues/(:volume)/(:number)/pdf' => 'frontend#issue_pdf', as: 'frontend_issue_pdf', constraints: {
    volume: /\d+/,
    number: /\d+/
  }

  # Ads manifest and relay
  get '/niceties/manifest' => 'frontend#ads_manifest', as: 'frontend_ads_manifest'
  get '/niceties/:id' => 'frontend#ads_relay', constraints: {id: /\d+/}, as: 'frontend_ads_relay'

  # RSS feed
  get '/feed' => 'frontend#feed', as: 'frontend_feed', defaults: {format: 'rss'}

  # Search
  get '/search/:type/(:query)(/page/:page)' => 'frontend#search', as: :frontend_search, defaults: {type: :articles}

  get '/:section_name/:id(/:slug)', controller: 'frontend_pieces', action: 'show_old_url', constraints: {id: /\d+/, section_name: /(news|world-and-nation|opinion|arts|sports|campus-life|fun|science)/}

  get '/:volume/:number/:archivetag' => 'frontend#legacy_article', constraints: {volume: /V\d+/, number: /N\d+/, archivetag: /[^\/]*\.html/}
  get '/:volume/:number/:parent/:archivetag' => 'frontend#legacy_article', constraints: {volume: /V\d+/, number: /N\d+/, parent: /.*/, archivetag: /.*\.html/}

  get '/:name', controller: 'frontend_static_pages', action: 'show', as: 'frontend_static_page', constraints: {name: /(ads(\/(index|schedule|policies|payment|adscontact))?)|(about(\/(index|contact|opinion_policy|comments|unpublish|copyright|publication_schedule|subscribe|special_projects|donate|join|staff))?)/}

  get '/ads/adinfo', controller: 'frontend_static_pages', action: 'adinfo'
  get '/ads/adinfo/:advertiser_type', controller: 'frontend_static_pages', action: 'adinfo', as: 'frontend_adinfo', constraints: {advertiser_type: /[^.]*/}

  post '/update_mast', controller: 'frontend_static_pages', action: 'update_mast'

  ##############################################################################
  # API routes
  ##############################################################################

  namespace :api do
    get 'issue_lookup/:volume/:issue', action: 'issue_lookup'
    get 'article_as_xml/:id', action: 'article_as_xml'
    get 'newest_issue'
    get 'article_parts'
    get 'style_mapping'
  end

  ##############################################################################
  # Backend routes
  ##############################################################################

  scope '/admin' do
    if ENV['MAINTENANCE'].present?
      match '*path', via: [:get, :post, :patch, :delete, :put], to: 'static_pages#maintenance'
      match '/', via: [:get, :post, :patch, :delete, :put], to: 'static_pages#maintenance'
    end

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
        post 'unpublish'
        patch 'add_article'
        patch 'remove_article'
      end
    end

    resources :articles, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      resources :drafts, only: [:index, :show, :update] do
        member do
          get 'revert'
          post 'publish'
          get 'below_fold_preview'
        end
      end

      member do
        patch 'update_rank'
        post 'unpublish'
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
end
