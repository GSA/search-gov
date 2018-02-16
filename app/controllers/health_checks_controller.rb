class HealthChecksController < ApplicationController
  def new
    check_database
    render text: 'OK'
  end

  def check_database
    Language.first
  end
end
