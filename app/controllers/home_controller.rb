class HomeController < ApplicationController
  has_mobile_fu

  def index
    @search = Search.new
    @title = "Home - "
    @active_top_searches = TopSearch.find_active_entries
  end

  def contact_form
    @title = "Contact Form - "
    if request.method == :post
      @email = params["email"]
      @message = params["message"]
      if @email.blank? || @message.blank?
        flash[:notice] = t(:contact_missing_required_fields)
      else
        if @email =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
          Emailer.deliver_mobile_feedback(@email, @message)
          flash[:notice] = t(:contact_thank_you)
          @thank_you = true
        else
          flash[:notice] = t(:contact_invalid_email)
        end
      end
    end
    respond_to do |format|
      format.html { render :file => File.join(RAILS_ROOT, "public", "404.html"), :status => 404 }
      format.mobile
    end
  end
end
