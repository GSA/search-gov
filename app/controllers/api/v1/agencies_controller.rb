# deprecated: SRCH-1574
module Api
  module V1
    class AgenciesController < ApplicationController
      respond_to :json

      def search
        @agency = AgencyQuery.find_by_phrase(params[:query]).agency
        respond_with(name: @agency.name, abbreviation: @agency.abbreviation,
                     organization_code: @agency.agency_organization_codes.first.organization_code)
      rescue Exception
        respond_with({ :error => "No matching agency could be found." }, :status => 404)
      end
    end
  end
end
