class HealthChecksController < ApplicationController
  ssl_allowed :all

  def new
    check_database
    render text: 'OK'
  end

  def check_database
    Language.first
  end
end
