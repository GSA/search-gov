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
        if @email =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
          Emailer.deliver_mobile_feedback(@email, @message)
          flash[:notice] = "Thank you. We have received your message and will be responding soon."
          @thank_you = true
        else
          flash[:notice] = "You must provide a valid email address."
        end
      end
    end
  end
end
