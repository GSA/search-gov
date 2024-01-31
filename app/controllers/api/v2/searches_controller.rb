# frozen_string_literal: true

module Api
  module V2
    class SearchesController < ApplicationController
      respond_to :json

      skip_before_action :set_default_locale
      before_action :validate_search_options
      before_action :handle_query_routing
      after_action :log_search_impression

      def blended
        @search = ApiBlendedSearch.new(@search_options.attributes)
        @search.run
        respond_with(@search)
      end

      def i14y
        @search = ApiI14ySearch.new(@search_options.attributes)
        @search.run
        respond_with(@search)
      end

      def video
        @search = ApiVideoSearch.new(@search_options.attributes)
        @search.run
        respond_with(@search)
      end

      # This endpoint is currently unused, but may be re-enabled in the future:
      # https://cm-jira.usa.gov/browse/SFL-46
      def docs
        @document_collection = (DocumentCollection.find(@search_options.dc) rescue nil)
        @search = ApiI14ySearch.new(@search_options.attributes)
        @search.run
        respond_with(@search)
      end

      private

      def handle_query_routing
        affiliate = @search_options.site
        routed_query = affiliate.routed_queries.
          joins(:routed_query_keywords).
          where(routed_query_keywords: { keyword: search_params[:query] }).
          first

        return unless routed_query

        RoutedQueryImpressionLogger.log(affiliate,
                                        @search_options.query, request)

        respond_with({ route_to: routed_query[:url] }, { status: 200 })
      end

      def search_params
        @search_params ||= params.permit(:access_key,
                                         :affiliate,
                                         :api_key,
                                         :audience,
                                         :content_type,
                                         :created_since,
                                         :created_until,
                                         :dc,
                                         :enable_highlighting,
                                         :filetype,
                                         :filter, # Advanced search "safe search" param
                                         :format,
                                         :include_facets,
                                         :limit,
                                         :mime_type,
                                         :offset,
                                         :query_not,
                                         :query_or,
                                         :query_quote,
                                         :query,
                                         :routed,
                                         :searchgov_custom1,
                                         :searchgov_custom2,
                                         :searchgov_custom3,
                                         :sitelimit,
                                         :sort_by,
                                         :tags,
                                         :updated_since,
                                         :updated_until).to_h

        # Mirrors param key renaming done for browser-based searches.
        # See: app/controllers/application_controller.rb #search_options_from_params
        @search_params[:site_limits] = @search_params.delete(:sitelimit)
        @search_params
      end

      def validate_search_options
        @search_options = search_options_validator_klass.new(search_params)
        return if @search_options.valid? && @search_options.valid?(:affiliate)

        respond_with({ errors: @search_options.errors.full_messages }, { status: 400 })
      end

      def search_options_validator_klass
        case action_name.to_sym
        when :blended, :video then Api::NonCommercialSearchOptions
        when :i14y then Api::I14ySearchOptions
        when :docs then Api::DocsSearchOptions
        end
      end

      def log_search_impression
        SearchImpression.log(@search, action_name, search_params, request)
      end
    end
  end
end
