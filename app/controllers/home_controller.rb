class HomeController < ApplicationController
  has_mobile_fu

  def index
    @search = Search.new
    @title = "Home - "
  end
  
  def contact_form
    @title = "Contact Form - "
    if request.method == :post
      @email = params["email"]
      @message = params["message"]
      if @email.blank? || @message.blank?
        flash[:notice] = "Missing required fields (*)"
      else
        if @email =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
          Emailer.deliver_mobile_feedback(@email, @message)
          flash[:notice] = "Thank you for contacting USA.gov. We will respond to you within two business days."
          @thank_you = true
        else
          flash[:notice] = "Email address is not valid"
        end
      end
    end
    respond_to do |format|
      format.html { render :file => File.join(RAILS_ROOT, "public", "404.html"), :status => 404 }
      format.mobile
    end
  end

  def serp_prototype
  
  end
  
  def serp_image_prototype
  
  end
end
