class RecommendationProvider < ActiveRecord::Base

  preference :recommended_product_count, :integer, :default => 5

  @provider = nil
  @@providers = Set.new
  def self.register
    @@providers.add(self)
  end

  def self.providers
    @@providers.to_a
  end
  
  named_scope :active, :conditions => {:active => true}
  named_scope :for_current_env, :conditions => ["environment IS NULL OR environment == '' OR environment = ?", ENV['RAILS_ENV']]

  def self.current
    @@current ||= active.for_current_env.first
  end


  def recommendations_for_products(products)
    raise 'Please implement recommendations_for_products in your own recommendation provider class'
  end

  def recommendations_for_user(user)
    raise 'Please implement recommendations_for_user in your own recommendation provider class'
  end
  
  private
  
    def limit_scope
      Product.limit(preferred_recommended_product_count)
    end

    def scope_from_product_ids(product_ids)
      limit_scope.scoped(:conditions => ['products.id IN (?)', product_ids] )
    end
    
    # Scope that produces no results in case of failure to get recommendations
    def empty_scope
      scope_from_product_ids([])
    end

end
