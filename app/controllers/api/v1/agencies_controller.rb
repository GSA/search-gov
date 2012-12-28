class Api::V1::AgenciesController < ApplicationController
  respond_to :json

  def search
    @agency = AgencyQuery.find_by_phrase(params[:query]).agency
    respond_with(@agency, only: [:name, :domain, :abbreviation, :organization_code, :phone, :twitter_username, :youtube_username, :facebook_username, :flickr_url])
  rescue Exception
    respond_with({:error => "No matching agency could be found."}, :status => 404)
  end
end
