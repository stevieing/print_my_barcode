Rails.application.routes.draw do

 
  namespace :v1 do

    mount Rswag::Ui::Engine => '/docs'
    mount Rswag::Api::Engine => '/docs'
    
    resources :sessions, only: [:create, :destroy]
    resources :label_types, only: [:index, :show, :create]

    resources :label_templates do
      member do
        post 'copy'
      end
    end

    resources :printers, only: [:index, :show, :create]
    resources :print_jobs, only: [:create]

  end

  match 'v1/test_exception_notifier', controller: 'application', action: 'test_exception_notifier', via: :get

end
