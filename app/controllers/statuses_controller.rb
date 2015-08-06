class StatusesController < SslController
  respond_to :text

  def outbound_rate_limit
    @status = OutboundRateLimitStatus.find_by_name params[:name]
    respond_with(@status) { |format| format.text { render text: @status } }
  end
end
