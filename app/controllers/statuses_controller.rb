# frozen_string_literal: true

class StatusesController < ApplicationController
  respond_to :text

  def domain_control_validation
    @affiliate = Affiliate.find_by(name: params[:affiliate])
    if @affiliate&.domain_control_validation_code
      render(plain: @affiliate.domain_control_validation_code)
    else
      render(plain: 'Domain Control Validation not configured', status: :not_found)
    end
  end
end
