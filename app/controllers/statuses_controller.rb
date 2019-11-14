class StatusesController < ApplicationController
  respond_to :text

  def outbound_rate_limit
    @status = OutboundRateLimitStatus.find_by_name(params[:name])
    respond_with(@status) { |format| format.text { render plain: @status } }
  end

  def domain_control_validation
    @affiliate = Affiliate.find_by(name: params[:affiliate])
    if @affiliate && @affiliate.domain_control_validation_code
      render(plain: @affiliate.domain_control_validation_code)
    else
      render(plain: 'Domain Control Validation not configured', status: :not_found)
    end
  end
end
