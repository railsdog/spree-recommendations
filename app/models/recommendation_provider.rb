class RecommendationProvider < ActiveRecord::Base
  
  @provider = nil
  @@providers = Set.new
  def self.register
    @@providers.add(self)
  end

  def self.providers
    @@providers.to_a
  end
  
  def self.available    
    all.select { |p| p.active and (p.environment == ENV['RAILS_ENV'] or p.environment.blank?) }
  end  
  
end
