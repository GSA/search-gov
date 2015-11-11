module SearchConsumer
  module Resources
    class Affiliates < Grape::API
      resource :affiliates do
        desc 'Affiliates Show', {
          params: SearchConsumer::Entities::Affiliate.documentation
        }

        params { requires :name }
        route_param :name do
          get do
            affiliate = Affiliate.find_by_name(params[:name])
            present affiliate, with: SearchConsumer::Entities::Affiliate
          end
        end

        desc 'Update an Affiliate.'
        params do
          requires :name, type: String, desc: 'Affiliate Site Handle.'
          requires :affiliate_params, type: Hash do
            requires :display_name, type: String
            requires :website, type: String
          end
        end
        put ':name' do
          Affiliate.find_by_name(params[:name]).update_attributes({
            display_name: params[:affiliate_params].display_name,
            website: params[:affiliate_params].website
          })
        end
      end
    end
  end
end