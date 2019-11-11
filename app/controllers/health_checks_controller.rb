class HealthChecksController < ApplicationController
  def new
    check_database
    render(plain: 'OK')
  end

  def check_database
    Language.first
  end
end
