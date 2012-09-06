class Api::V1::FormsController < ApplicationController
  JSON_OPTIONS = {:include => {:form_agency => {:except => [:updated_at, :created_at]}},
                  :except => [:updated_at, :created_at, :form_agency_id]}
  before_filter :set_params, :only => :search
  before_filter :find_form, :only => :show

  ssl_allowed :all

  respond_to :json

  def show
    respond_with(@form, JSON_OPTIONS)
  end

  def search
    respond_with(Form.search_for(@query, @options).results, JSON_OPTIONS)
  rescue Exception
    respond_with({:error => "There was an error processing your request. Please try again later"}, :status => 400)
  end

  private

  def set_params
    @query = sanitize_query(params.delete(:query)) || ''
    params[:verified] = true if params[:verified] =~ /true/i
    params[:verified] = false if params[:verified] =~ /false/i
    params[:form_agencies] = params[:form_agencies].split(',').map{|id_str| id_str.to_i} if params[:form_agencies]
    @options = params
  end

  def find_form
    @form = Form.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_with({:error => "The form you were looking for could not be found."}, :status => 404)
  end
end
