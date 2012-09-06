class Api::V1::FormsController < ApplicationController
  before_filter :set_params, :only => :search
  before_filter :find_form, :only => :show

  ssl_allowed :search, :show

  respond_to :json

  def show
    respond_with @form
  end

  def search
    response = Form.search_for(@query, @options).results rescue []
    respond_with response
  end

  private

  def set_params
    @query = sanitize_query(params.delete(:query)) || ''
    params[:govbox_enabled] = true if params[:govbox_enabled] =~ /true/i
    params[:govbox_enabled] = false if params[:govbox_enabled] =~ /false/i
    @options = params
  end

  def find_form
    @form = Form.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    respond_with({:error => "The form you were looking for could not be found."}, :status => 404)
  end
end
