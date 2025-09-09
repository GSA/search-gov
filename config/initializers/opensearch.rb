require 'elasticsearch'

ES_OS = Elasticsearch::Client.new(
  url: ENV['OS_URL'] || 'http://localhost:9200',
  log: Rails.env.development?
)
