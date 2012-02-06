class HomeController < ApplicationController
  has_mobile_fu

  def index
    @search = WebSearch.new
    @title = "Home - "
    @affiliate = I18n.locale == :es ? Affiliate.find_by_name('gobiernousa') : Affiliate.find_by_name('usagov')
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
