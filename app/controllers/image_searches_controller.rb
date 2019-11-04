class ImageSearchesController < ApplicationController
  include MobileFriendlyController

  layout 'searches'

  before_action :set_affiliate, :set_locale_based_on_affiliate_locale
  before_action :set_header_footer_fields
  before_action :set_search_options
  before_action :force_request_format

  def index
    @search = search_klass.new(@search_options)
    @search.run
    @page_title = @search.query
    set_search_page_title
    @search_vertical = :image
    set_search_params
    SearchImpression.log(@search, @search_vertical, params, request)
    respond_to do |format|
      format.any(:html, :mobile) {}
      format.json { render :json => @search }
    end
  end

  private

  def set_search_options
    @search_options = {
        affiliate: @affiliate,
        cr: permitted_params[:cr],
        page: permitted_params[:page],
        query: sanitize_query(permitted_params[:query]) || ''
    }
  end

  def search_klass
    @affiliate.force_mobile_format? ? ImageSearch : LegacyImageSearch
  end
end
