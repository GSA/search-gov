module Api
  module V2
    class SearchesController < ApplicationController
      respond_to :json

      skip_before_action :set_default_locale
      before_action :validate_search_options
      before_action :handle_query_routing
      after_action :log_search_impression

      def blended
        @search = ApiBlendedSearch.new @search_options.attributes
        @search.run
        respond_with @search
      end

      def azure
        @search = ApiAzureSearch.new @search_options.attributes
        @search.run
        respond_with @search
      end

      def azure_web
        @search = ApiAzureCompositeWebSearch.new @search_options.attributes
        @search.run
        respond_with @search
      end

      def azure_image
        @search = ApiAzureCompositeImageSearch.new @search_options.attributes
        @search.run
        respond_with @search
      end

      def bing
        @search = ApiBingSearch.new @search_options.attributes
        @search.run
        respond_with @search
      end

      def gss
        @search = ApiGssSearch.new @search_options.attributes
        @search.run
        respond_with @search
      end

      def i14y
        @search = ApiI14ySearch.new @search_options.attributes
        @search.run
        respond_with @search
      end

      def video
        @search = ApiVideoSearch.new @search_options.attributes
        @search.run
        respond_with @search
      end

      def docs
        @document_collection = (DocumentCollection.find(@search_options.dc) rescue nil)
        if @document_collection and @document_collection.too_deep_for_bing?
          @search = ApiI14ySearch.new @search_options.attributes
        else
          @search = affiliate_docs_search_class.new(@search_options.attributes)
        end
        @search.run
        respond_with @search
      end

      private

      def affiliate_docs_search_class
        case @search_options.site.search_engine
        when %r{BingV\d+}
          ApiBingDocsSearch
        when 'Google'
          ApiGoogleDocsSearch
        end
      end

      def handle_query_routing
        return unless search_params[:query].present? and query_routing_is_enabled?
        affiliate = @search_options.site
        routed_query = affiliate.routed_queries
          .joins(:routed_query_keywords)
          .where(routed_query_keywords:{keyword: search_params[:query]})
          .first
        respond_with({ redirect: routed_query[:url] }, { status: 200 }) unless routed_query.nil?
      end

      def query_routing_is_enabled?
        search_params[:routed] == 'true'
      end

      def search_params
        @search_params ||= params.permit(:access_key,
                                         :affiliate,
                                         :dc,
                                         :api_key,
                                         :cx,
                                         :enable_highlighting,
                                         :format,
                                         :limit,
                                         :offset,
                                         :query,
                                         :sort_by,
                                         :sc_access_key,
                                         :routed,
                                         :query_not,
                                         :query_quote,
                                         :query_or,
                                         :filetype,
                                         :filter
                                       ).to_h

      end

      def validate_search_options
        @search_options = search_options_validator_klass.new search_params
        unless @search_options.valid? && @search_options.valid?(:affiliate)
          obfuscate_sc_access_key_error if sc_access_key_error.present?
          respond_with({ errors: @search_options.errors.full_messages }, { status: 400 })
        end
      end

      def search_options_validator_klass
        case action_name.to_sym
        when :azure then Api::CommercialSearchOptions
        when :azure_web then Api::AzureCompositeWebSearchOptions
        when :azure_image then Api::AzureCompositeImageSearchOptions
        when :bing then Api::SecretAPISearchOptions
        when :blended, :i14y, :video then Api::NonCommercialSearchOptions
        when :gss then Api::GssSearchOptions
        when :docs then Api::DocsSearchOptions
        end
      end

      def sc_access_key_error
        @search_options.errors[:sc_access_key]
      end

      def obfuscate_sc_access_key_error
        @search_options.errors.delete :sc_access_key
        @search_options.errors[:hidden_key] = 'is required'
      end

      def log_search_impression
        SearchImpression.log(@search, action_name, search_params, request)
      end
    end
  end
end
