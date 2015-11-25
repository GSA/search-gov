module SearchConsumer
  module Resources
    class Affiliates < Grape::API
      resource :affiliates do
        desc 'Affiliates', {
          params: SearchConsumer::Entities::Affiliate.documentation
        }

        params { requires :name }
        route_param :name do
          get do
            affiliate = Affiliate.find_by_name(params[:name])
            present affiliate, with: SearchConsumer::Entities::Affiliate
          end

          desc 'Return all facets and search modules settings in order of Priority'
          get '/config' do
            affiliate = Affiliate.find_by_name(params[:name])
            present :page_one_label, affiliate.default_search_label
            present :facets, affiliate.navigations, with: SearchConsumer::Entities::Facets
            present :modules, affiliate, with: SearchConsumer::Entities::SearchModules
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
          attributes = {
            display_name: params[:affiliate_params].display_name,
            website: params[:affiliate_params].website
          }
          Affiliate.find_by_name(params[:name]).update_attributes(attributes)
        end
      end
    end
  end
end