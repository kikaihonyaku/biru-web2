Rails.application.routes.draw do
  root "home#index"
  # root to: "pages#index"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # API routes for Cosmos React app
  namespace :api do
    namespace :v1 do
      get 'properties/map_data', to: 'properties#map_data'
      post 'properties/search', to: 'properties#search'
      get 'layers/:type', to: 'layers#show'
      
      # CORS preflight requests
      match 'properties/*path', to: 'properties#options', via: :options
      match 'layers/*path', to: 'layers#options', via: :options
    end
  end

  # React Router に任せたいパスを全部 index に返す（APIは除外）
  get "*path", to: "home#index", constraints: ->(req) do
    req.format.html? && !req.path.start_with?("/rails", "/assets", "/api")
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"


  get "performance_build_age/index"

  get "performance_build_age/display"

  get "biru_service/index"

  get "biru_service/map"

  resources :biru_user_monthlies


  get "building_rooms/index"

  resources :biru_users

  put "mail_reactions/delete_update" => "mail_reactions#delete_update"
  put "mail_reactions/update_shop" => "mail_reactions#update_shop"
  put "mail_reactions/update_response" => "mail_reactions#update_response"
  resources :mail_reactions


  #  resources :owners

  get "repairs/index", as: :repairs

  get "pages/page_menu01" => "pages#menu01", :as => :page_menu01
  get "pages/page_menu02" => "pages#menu02", :as => :page_menu02
  get "pages/page_menu03" => "pages#menu03", :as => :page_menu03
  get "pages/page_menu04" => "pages#menu04", :as => :page_menu04
  get "pages/page_menu05" => "pages#menu05", :as => :page_menu05

  get "biru_service/index(/:room_all)" => "biru_service#index", :as => :biru_service
  get "biru_service/map(/:room_all)" => "biru_service#map"

  get "property/index(/:neighborhood)" => "property#index", :as => :property
  get "property/map(/:neighborhood)" => "property#map"

  get "property/search" => "property#search", :as => :property_search

  get "trust_rewinding/index", as: :trust_rewinding

  get "renters/index(/:sakimono)" => "renters#index", :as => :renters


  match "renters/update_all", as: :renters_update_all, via: :all
  get "renters/pictures/:id" => "renters#pictures", :as => :renters_pictures

  get "owners/index", as: :owners

  get "recruitments/index", as: :recruitments

  get "managements/index", as: :managements
  get "trust_managements/index", as: :trust_managements
  get "trust_managements/trust_user_report", as: :trust_user_report
  get "trust_managements/owner_building_list", as: :owner_building_list

  get "building_rooms/index", as: :building_rooms

  get "performances/index", as: :performances
  get "performances/monthly", as: :performances_monthly
  get "performances/build_age", as: :performances_build_age
  get "performances/vacant_day", as: :performances_vacant_day
  get "performances/tenancy_period", as: :performances_tenancy_period
  get "login/logout", as: :logout

  get "performance_monthly/index", as: :performance_monthly
  get "performance_monthly/display", as: :performance_monthly_display

  get "performance_build_age/index", as: :performance_build_age
  # get "performance_build_age/display", as: :performance_build_age_display

  get "comments/index", as: :comments

  get "managements/popup_owner/:id" => "managements#popup_owner", :as =>:popup_owner
  get "/recruitments/search_around", as: :search_around

  match "managements/bulk_search_file", as: :bulk_search_file, via: :all
  match "managements/bulk_search_text", as: :bulk_search_text, via: :all

  get "managements/popup_owner_documents_download/:document_id" => "managements#popup_owner_documents_download", :as => :popup_owner_documents_download

  get "trust_managements/popup_owner_buildings/:owner_id" => "trust_managements#popup_owner_buildings", :as => :popup_owner_buildings
  get "trust_managements/popup_owner_create" => "trust_managements#popup_owner_create", :as => :popup_owner_create

  # trust_management
  get "trust_managements/owner_show/:id" => "trust_managements#owner_show", :as => :owner_show
  get "trust_managements/building_show/:id" => "trust_managements#building_show", :as => :building_show
  # post "trust_managements/owner_update/id" => 'trust_managements#owner_update', :as => :owner_update

  get "kss/exec_raiten/:month" => "kss#exec_raiten", :as => :kss_exec_raiten
  get "kss/exec_chintai/:month" => "kss#exec_chintai", :as => :kss_exec_chintai
  get "kss/exec_kanri_bukken/:month" => "kss#exec_kanri_bukken", :as => :kss_exec_kanri_bukken

  get "kss/exec_kouji_uriage/:month" => "kss#exec_kouji_uriage", :as => :exec_kouji_uriage
  get "kss/exec_check_all/:month" => "kss#exec_check_all", :as => :exec_check_all
  get "kss/exec_mail_reaction/:month" => "kss#exec_mail_reaction", :as => :exec_mail_reaction

  get "kss/exec_check_keiyaku/:month" => "kss#exec_check_keiyaku", :as => :kss_exec_check_keiyaku
  get "kss/exec_check_taikyo/:month" => "kss#exec_check_taikyo", :as => :kss_exec_check_taikyo
  get "kss/exec_check_tasyakeiyaku/:month" => "kss#exec_check_tasyakeiyaku", :as => :kss_exec_check_tasyakeiyaku
  get "kss/exec_trust_attack/:month" => "kss#exec_trust_attack", :as => :kss_exec_trust_attack

  get "kss/exec_nyuukyo_point/:month" => "kss#exec_nyuukyo_point", :as => :kss_exec_nyuukyo_point

  get "constructions/popup/:code" => "constructions#popup", :as => :constructions_popup
  resources :constructions

  # ↓これはActiveAdmin.routesよりは下にないと、メンテナンスでeditをする際に適応されて
  # 誤動作してしまう。
  match ":controller(/:action(/:id))", via: :all

  get "pages/index"
  match "managements/search_buildings", via: :all
  match "managements/search_owners", via: :all
end
