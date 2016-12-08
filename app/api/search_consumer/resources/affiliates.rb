module SearchConsumer
  module Resources
    class Affiliates < Grape::API
      resource :affiliate do
        params { requires :site_handle, type: String, desc: 'Affiliate Site Handle.' }
        desc 'Return all facets and search modules settings in order of Priority'
        get '/config' do
          affiliate = Affiliate.find_by_name(params[:site_handle])

          error! "That Affiliate does not exist in the `usasearch` DB", 400  unless affiliate

          present :defaults, affiliate, with: SearchConsumer::Entities::Defaults
          present :facets, affiliate, with: SearchConsumer::Entities::Facets
          present :footer, affiliate, with: SearchConsumer::Entities::Footer
          present :header, affiliate, with: SearchConsumer::Entities::Header
          present :headerLinks, affiliate, with: SearchConsumer::Entities::HeaderLinks
          present :govBoxes, affiliate, with: SearchConsumer::Entities::GovBoxes
          present :noResultsPage, affiliate, with: SearchConsumer::Entities::NoResultsPage
          present :resultsContainer, affiliate, with: SearchConsumer::Entities::ResultsContainer
          present :searchBar, affiliate, with: SearchConsumer::Entities::SearchBar
          present :searchPageAlert, affiliate.alert, with: SearchConsumer::Entities::SearchPageAlert
          present :tagline, affiliate, with: SearchConsumer::Entities::Tagline
          present :template, affiliate, with: SearchConsumer::Entities::Template
          present :related_sites, affiliate.connections, with: SearchConsumer::Entities::RelatedSites
          present :document_collections, affiliate.document_collections,
            with: SearchConsumer::Entities::DocumentCollections
        end
      end
    end
  end
end
