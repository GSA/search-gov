class HomeController < ApplicationController
  has_mobile_fu
  before_filter :set_affiliate_based_on_locale_param, :only => [:index]
  before_filter :set_locale_based_on_affiliate_locale, :only => [:index]
  before_filter :set_locale, :only => [:contact_form]

  def index
    @title = "Home - "
    @search = WebSearch.new(:affiliate => @affiliate)
    respond_to do |format|
      format.any(:html, :mobile)
    end
  end

  def contact_form
    @title = "Contact Form - "
    if request.method == "POST"
      @email = params["email"]
      @message = params["message"]
      if @email.blank? || @message.blank?
        flash[:notice] = t(:contact_missing_required_fields)
      else
        if @email =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
          Emailer.mobile_feedback(@email, @message).deliver
          flash[:notice] = t(:contact_thank_you)
          @thank_you = true
        else
          flash[:notice] = t(:contact_invalid_email)
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to(page_not_found_path) }
      format.mobile
    end
  end
end
