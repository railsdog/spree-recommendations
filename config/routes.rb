map.namespace :admin do |admin|
  admin.resources :recommendation_providers
end

map.connect 'api/export/:action', :controller => 'api/export'
