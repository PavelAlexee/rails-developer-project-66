Rails.application.routes.draw do
  root 'web/home#show'

  scope module: :web do
    post 'auth/:provider', to: 'auth#request', as: :auth_request
    get 'auth/:provider/callback', to: 'auth#callback', as: :callback_auth
    delete 'auth/logout', to: 'auth#destroy'

    resources :repositories, only: [:index, :new, :create, :destroy]

  end
end
