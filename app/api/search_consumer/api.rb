module SearchConsumer
  class Api < Grape::API
    format :json

    before_validation do
      error!('401 Unauthorized', 401) unless params[:sc_access_key] == SC_ACCESS_KEY
    end

    mount SearchConsumer::Resources::Affiliates
    mount SearchConsumer::Resources::RssSearch
  end
end

