# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class RecommendationsExtension < Spree::Extension
  version "1.0"
  description "Describe your extension here"
  url "http://yourwebsite.com/recommendations"

  # Please use recommendations/config/routes.rb instead for extension routes.

  # def self.require_gems(config)
  #   config.gem "gemname-goes-here", :version => '1.2.3'
  # end
  
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
  end
end
