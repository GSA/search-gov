# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '/assets/*', headers: :any, methods: %i[get head options]
    resource '/api/v2/click', headers: :any, methods: %i[post head options]
    resource '/api/v2/search/*', headers: :any, methods: %i[get head options]
    resource '/sayt', headers: :any, methods: %i[get head options]
  end
end
