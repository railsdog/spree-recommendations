class CreateRecommendationProviders < ActiveRecord::Migration
  def self.up
    create_table :recommendation_providers do |t|
      t.timestamps
      t.string   "type"
      t.string   "name"
      t.text     "description"
      t.boolean  "active",      :default => true
      t.string   "environment", :default => "development"
    end
  end

  def self.down
    drop_table :recommendation_providers
  end
end
