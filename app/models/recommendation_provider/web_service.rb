class RecommendationProvider::WebService < RecommendationProvider

  preference :service_url, :string, :default => 'http://localhost:8080/recommend'

  def recommendations_for_products(products)
    get_recommendations(product_recommendations_url(products))
  end

  def recommendations_for_user(user)
    get_recommendations(user_recommendations_url(user))
  end

  private

    def get_recommendations(url)
      begin
        response = HTTParty.get(url)
      rescue Exception => e
        log_service_error(url, e.inspect)
        return empty_scope
      end
      if response.code == 200
        scope_from_product_ids(parse_response_body(response.body))
      else
        log_service_error(url, "response: #{response.code} (#{response.message})\n#{response.body}")
        empty_scope
      end
    end

    def product_recommendations_url(products)
      "#{preferred_service_url}?productss=" + products.map(&:id).join(',')
    end
      
    def user_recommendations_url(user)
      "#{preferred_service_url}?user=#{user.id}"
    end
    
    # Get an array of product ids from the service response body
    def parse_response_body(response_body)
      response_body.to_s.split.map(&:to_i)
    end

    def log_service_error(url, description)
      logger.error "Recommendation service error"
      logger.error "  url: #{url}"
      logger.error "  provider: #{self.inspect}"
      logger.error description
    end

end