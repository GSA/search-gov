class StatusesController < ApplicationController
  respond_to :text

  def outbound_rate_limit
    @status = OutboundRateLimitStatus.find_by_name params[:name]
    respond_with(@status) { |format| format.text { render text: @status } }
  end

  def domain_control_validation
    @affiliate = Affiliate.find_by_name(params[:affiliate])
    if @affiliate && @affiliate.domain_control_validation_code
      render text: @affiliate.domain_control_validation_code
    else
      render text: 'Domain Control Validation not configured', status: 404
    end
  end
end
