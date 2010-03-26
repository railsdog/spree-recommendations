# Spree Recommendations Extension

Provide customers with production recommendations based on what other customers bought. 

Different providers may be configured for different environments.

Extendable with new recommendation providers by extending *RecommendationProvider*

    # Get recommendations based on a product. Returns a scope for further filtering
    @product.recommendations
    
    # Provide recommendations based on a user's purchasing history
    @user.recommendations

