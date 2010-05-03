# Spree Recommendations Extension

Provides customers with production recommendations based on what other customers bought. 
Allows different providers to be configured for different environments.

Extendable with new recommendation providers by extending the *RecommendationProvider* class.

## Basic usage

The extension will add a list of recommended products to the product details screen, provided an active recommendation provider is
found for the current environment and some recommendations are found for that product. 

These are rendered with the partial *products/_recommendations.html.erb*

To get recommendations based on a product. Returns a scope for further filtering

    @product.recommendations

Provide recommendations based on a user's purchasing history

    @user.recommendations


## Configuration

### Adding a recommendation provider

Recommendation providers may be configured in the admin interface under the 'Configurations' tab. The provider is used based on the current environment and activate status of the provider.

### Built in providers

*RecommendationProvider::Bogus* provides fake results for situations where its not possible or necessary 
to run a real recommendation service.

*RecommendationProvider::Mahout* fetches recommendation from a web service. This is intended for use with the spree-mahout server but can be used with any web service that provides the expected response.
The service is called as follows:

    /recommend?products=1,2 # 
    /recommend?user=1

The response is simply a list of product ids separated by newlines.


## Writing a new recommendation provider

### Writing a provider class

Your provider class should extend *RecommendationProvider*:

    class RecommendationProvider::MyProvider < RecommendationProvider
    end

This class should implement the following 2 methods.

    recommendations_for_products(products)
    recommendations_for_user(user)

Both methods should return a Product scope object that limits by id. The private method *scope_from_product_ids* assists with this.

### Register your provider

To make your provider available for configuration in the admin interface it must first be registered. Add the following to
your extension's *activate* method:

    RecommendationProvider::MyProvider.register



## Spree Mahout server

A basic java servlet to provide recommendations from Mahout is available here: https://github.com/railsdog/spree-mahout.

Data is loaded from *src/data.txt*. The format of this file is as follows:

    user_id, product_id, preference

Each line represents a user's preference for a given product, for example a purchase or review. 
The preference value indicates the relative weight this preference will have when evaluating recommendations.

To start the server, simply run:

    ./start

The server will be available at *http://localhost:8080/recommend*

