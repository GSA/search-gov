module SearchConsumer
  module Resources
    class RssSearch < Grape::API
      resource :search do
        resource :rss do
          desc 'Channel', {
            params: SearchConsumer::Entities::RssSearch.documentation
          }

          desc 'Return the Channel\'s search results'
          params do
            requires :affiliate, type: String, desc: 'Affiliate Site Handle.'
            requires :channel, type: String
            requires :query, type: String
          end
          route_param :channel do
            get do
              affiliate = Affiliate.active.find_by_name(params[:affiliate])
              search = NewsSearch.new(params.merge(affiliate: affiliate))
              search.run
              present search, with: SearchConsumer::Entities::RssSearch
            end
          end
        end
      end
    end
  end
end
