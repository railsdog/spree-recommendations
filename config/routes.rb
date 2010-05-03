map.namespace :admin do |admin|
  admin.resources :recommendation_providers
  admin.resources :products, :member => {:recommendations => :get}
end

map.connect 'api/export/:action', :controller => 'api/export'
map.connect 'api/export/:action/:year/:month/:day', :controller => 'api/export'
