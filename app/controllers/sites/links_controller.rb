# frozen_string_literal: true

class Sites::LinksController < Sites::SetupSiteController
  def new
    @index       = params[:position].to_i
    @fields_name = params[:type].underscore.pluralize
    @html_id     = @fields_name.dasherize
    @link        = Link.new(type: params[:type], position: @index)

    respond_to { |format| format.js }
  end
end
