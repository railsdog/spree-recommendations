# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class RecommendationsExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/recommendations"

  def activate
		#register all recommendation providers
		[
			RecommendationProvider::Bogus,
			RecommendationProvider::Mahout
    ].each{|rp|
      begin
        rp.register  
      rescue Exception => e
        $stderr.puts "Error registering recommendation provider #{rp}: #{e}"
      end
    }
    
    
    Product.class_eval do
      def recommendations
        RecommendationProvider.current.recommendations_for_products([self])
      end
    end

    User.class_eval do
      def recommendations
        RecommendationProvider.current.recommendations_for_user(self)
      end
    end

  end
end
