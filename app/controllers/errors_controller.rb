# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout 'searches_redesign'

  def invalid_affiliate
    @page_title = 'Your search did not work'
    render status: :not_found, formats: [:html]
  end

  def inactive_affiliate
    @page_title = 'Search Temporarily Unavailable'
    render status: :not_found, formats: [:html]
  end
end
