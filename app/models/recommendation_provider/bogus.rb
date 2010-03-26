# Provide fake recommendations when its not convenient or necessary to run a real recommendation provider service
# Recommendations are provided as a product scope to allow further filtering or ordering
class RecommendationProvider::Bogus < RecommendationProvider
  
  def recommendations_for_products(products)
    limit_scope.scoped(:conditions => ['products.id NOT IN (?)', products.map(&:id)] )
  end

  def recommendations_for_user(user)
    limit_scope
  end

end