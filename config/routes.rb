TrippingOcto::Application.routes.draw do

  root :to => 'main#index'

  match "administracao" => "administracao#index"
  namespace :administracao do

    resources :entidades
    resources :usuario_administradores

    match "sign_in" => "session#new", as: "sign_in"
    match "sign_out" => "session#destroy", as: "sign_out"
    resources :session, only: [:new, :create, :destroy]
  end

  match ":entidade_slug" => "entidade#index", as: "entidade"
  scope ":entidade_slug", as: "entidade", module: "modulo_entidade" do

    match "administracao" => "administracao#index"
    namespace :administracao do
      resources :metas
      resources :usuario_entidades
      resources :item_importacao_jobs do
        member do
          get :download_file
        end
      end
      resources :importacoes do
        member do
          post :load_header_of_spreadsheet
        end
        collection do
          get :jobs
        end
        resources :item_importacoes do
          member do
            get :execute

          end
        end
      end

      resources :unidades

      resources :clientes
      resources :cliente_temps

      resources :produtos
      resources :produto_temps

      resources :nota_fiscais
      resources :nota_fiscal_temps

      resources :vendedores
      resources :vendedor_temps

      resources :conjunto_indicadores do
        collection do
          match :validar_new
        end
        member do
          match :validar_edit
        end
      end


      namespace :relatorios do
        resources :volumes
        
        resources :carteiras do
          collection do
            post :run_carteira
            post :carrega_dias_uteis
            post :carrega_anos_meses
            post :carrega_dados_indicadores
          end
        end

      end


    end

    # NÍVEL DA UNIDADE
    resources :dashboards

    match "sign_in" => "session#new", as: "sign_in"
    match "sign_out" => "session#destroy", as: "sign_out"
    match "select_unidades" => "session#select_unidades", as: "select_unidades"
    match "save_unidades" => "session#save_unidades", as: "save_unidades"
    resources :session, only: [:new, :create, :destroy]
  end
end
