module SearchConsumer
  module Resources
    class RssChannel < Grape::API
      resource :search do
        resource :rss do
          desc 'Channel', {
            params: SearchConsumer::Entities::RssChannel.documentation
          }

          desc 'Return the Channel\'s search results'
          params do
            requires :site_handle, type: String, desc: 'Affiliate Site Handle.'
            requires :channel, type: String
            requires :query, type: String
          end
          route_param :channel do
            get do
              affiliate = Affiliate.find_by_name(params[:site_handle])
              search = NewsSearch.new(params.merge(affiliate: affiliate))
              search.run
              present search, with: SearchConsumer::Entities::RssChannel
            end
          end
        end
      end
    end
  end
end