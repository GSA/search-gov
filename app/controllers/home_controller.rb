class HomeController < ApplicationController
  has_mobile_fu
  def index
    @search = Search.new
  end
  
  def contact_form
    if request.method == :post
      @email = params["email"]
      @message = params["message"]
      if @email.blank? || @message.blank?
        flash[:notice] = "You must fill in all required fields marked by an '*'"
      else
        Emailer.deliver_mobile_feedback(@email, @message)
        flash[:notice] = "Thank you.  We have received your message and will be responding soon."
        @thank_you = true
      end
    end
  end
end
