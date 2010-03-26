# Spree Recommendations Extension

Provide customers with production recommendations based on what other customers bought. 

Different providers may be configured for different environments.

Extendable with new recommendation providers by extending the *RecommendationProvider* class

RecommendationProvider::Bogus provides fake results for situations where its not possible or necessary 
to run a real recommendation service.


    # Register your provider
    RecommendationProvider::MyProvider.register

    # Get recommendations based on a product. Returns a scope for further filtering
    @product.recommendations
    
    # Provide recommendations based on a user's purchasing history
    @user.recommendations

