module SearchConsumer
  module Resources
    class Affiliates < Grape::API
      resource :affiliate do
        desc 'Affiliates', {
          params: SearchConsumer::Entities::Affiliate.documentation
        }

        params { requires :site_handle, type: String, desc: 'Affiliate Site Handle.' }
        get do
          affiliate = Affiliate.find_by_name(params[:site_handle])
          present affiliate, with: SearchConsumer::Entities::Affiliate
        end

        params { requires :site_handle, type: String, desc: 'Affiliate Site Handle.' }
        desc 'Return all facets and search modules settings in order of Priority'
        get '/config' do
          affiliate = Affiliate.find_by_name(params[:site_handle])
          present :page_one_label, affiliate.default_search_label
          present :facets, affiliate.navigations, with: SearchConsumer::Entities::Facets
          present :modules, affiliate, with: SearchConsumer::Entities::SearchModules
        end

        desc 'Update an Affiliate.'
        params do
          requires :site_handle, type: String, desc: 'Affiliate Site Handle.'
          requires :affiliate_params, type: Hash do
            requires :display_name, type: String
            requires :website, type: String
          end
        end
        put do
          attributes = {
            display_name: params[:affiliate_params].display_name,
            website: params[:affiliate_params].website
          }
          Affiliate.find_by_name(params[:site_handle]).update_attributes(attributes)
        end
      end
    end
  end
end