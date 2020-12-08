# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '/assets/*', headers: :any, methods: %i[get head options]
    resource '/api/v2/click', headers: :any, methods: %i[post head options]
    resource '/api/v2/search', headers: :any, methods: %i[get head options]
    resource '/sayt', headers: :any, methods: %i[get head options]
  end
end
