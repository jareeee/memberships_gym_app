Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  root 'dashboard#show'

  get 'memberships', to: 'memberships#index'
  get 'memberships/payment', to: 'memberships#show_payment'
  post 'memberships/payment', to: 'memberships#payment'

  get 'memberships/paid', to: 'memberships#paid'
end
