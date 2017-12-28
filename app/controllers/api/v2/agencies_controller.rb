class Api::V2::AgenciesController < ApplicationController
  respond_to :json

  def search
    @agency = AgencyQuery.find_by_phrase(params[:query]).agency
    respond_with(name: @agency.name, abbreviation: @agency.abbreviation,
                 organization_codes: @agency.agency_organization_codes.collect(&:organization_code))
  rescue Exception
    respond_with({ :error => "No matching agency could be found." }, :status => 404)
  end
end
