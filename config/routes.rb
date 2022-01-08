Rails.application.routes.draw do
  get 'mangas/index'
  resources :mangas, only: %i(index)
  # root 'mangas#index'

  resources :products
  root 'products#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
