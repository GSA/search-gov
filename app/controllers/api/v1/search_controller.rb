# frozen_string_literal: true

module Api
  module V1
    class SearchController < ApplicationController
      DEPRECATION_MESSAGE = 'This API endpoint has been deprecated. Please refer to https://search.gov/developer/ for information on current Search.gov APIs.'

      def search
        render plain: DEPRECATION_MESSAGE, status: :not_found
      end
    end
  end
end
