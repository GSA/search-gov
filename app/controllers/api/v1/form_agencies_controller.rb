class Api::V1::FormAgenciesController < ApplicationController
  JSON_OPTIONS = {:except => [:updated_at, :created_at]}
  before_filter :find_form_agency, :only => :show

  ssl_allowed :all

  respond_to :json

  def index
    respond_with(FormAgency.all, JSON_OPTIONS)
  end

  def show
    respond_with(@form_agency, JSON_OPTIONS)
  end

  private

  def find_form_agency
    @form_agency = FormAgency.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_with({:error => "The form agency you were looking for could not be found."}, :status => 404)
  end
end
