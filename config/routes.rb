Rails.application.routes.draw do
  default_url_options host: 'localhost:3000'
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  root 'dashboard#show'

  get 'memberships', to: 'memberships#index'
  get 'memberships/payment', to: 'memberships#show_payment'
  get 'memberships/paid', to: 'memberships#paid'
  post 'memberships/payment', to: 'memberships#payment'

  post '/stripe/webhooks', to: 'stripe_webhooks#create'

  get '/check-in', to: 'check_ins#new', as: :new_check_in
  post '/check-in', to: 'check_ins#create', as: :check_in

  scope 'profile' do
    get '/', to: 'profile#show', as: :profile
    patch '/update', to: 'profile#update', as: :update_profile
  end
end
