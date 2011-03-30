class Affiliates::HomeController < Affiliates::AffiliatesController
  before_filter :require_affiliate_or_admin, :except=> [:index, :edit_site_information, :edit_look_and_feel, :how_it_works, :demo]
  before_filter :require_affiliate, :only => [:edit_site_information, :edit_look_and_feel, :preview]
  before_filter :require_approved_user, :except => [:index, :how_it_works, :demo, :home, :update_contact_information]
  before_filter :setup_affiliate, :only=> [:edit_site_information, :update_site_information, :edit_look_and_feel, :update_look_and_feel, :show, :preview, :push_content_for, :cancel_staged_changes_for, :destroy]
  before_filter :sync_affiliate_staged_attributes, :only => [:edit_site_information, :edit_look_and_feel]

  AFFILIATE_ADS = [
    {:display_name => "BROWARD.org",
     :url => "http://www.broward.org",
     :thumbnail => "thumb_broward.png"},
    {:display_name => "CT.gov",
     :url => "http://www.ct.gov",
     :thumbnail => "thumb_ct.png"},
    {:display_name => "DATA.gov",
     :url => "http://data.gov",
     :thumbnail => "thumb_datagov.png"},
    {:display_name => "DOI.gov",
     :url => "http://www.doi.gov",
     :thumbnail => "thumb_doi.png"},
    {:display_name => "IMLS.gov",
     :url => "http://imls.gov",
     :thumbnail => "thumb_imls.png"},
    {:display_name => "Navajo County",
     :url => "http://www.navajocountyaz.gov",
     :thumbnail => "thumb_navajo.png"},
    {:display_name => "National Park Service",
     :url => "http://www.nps.gov",
     :thumbnail => "thumb_nps.png"},
    {:display_name => "National Weather Service",
     :url => "http://www.nws.gov",
     :thumbnail => "thumb_nws.png"},
    {:display_name => "City of Reno, Nevada",
     :url => "http://reno.gov",
     :thumbnail => "thumb_reno.png"},
    {:display_name => "www.nan.usace.army.mil",
     :url => "http://www.nan.usace.army.mil",
     :thumbnail => "thumb_usace.png"},
    {:display_name => "WSDOT.wa.gov",
     :url => "http://wsdot.wa.gov",
     :thumbnail => "thumb_wsdot.png"},
  ]

  UPDATE_ACTION_HASH = {
    :update_site_information => {
      :title => 'Site Information - ',
      :edit_action => :edit_site_information },
    :update_look_and_feel => {
      :title => "Look and Feel of the Search Results Page - ",
      :edit_action => :edit_look_and_feel }
  }

  def index
    @title = "USASearch Affiliate Program - "
  end

  def edit_site_information
    @title = "Site Information - "
  end

  def edit_look_and_feel
    @title = "Look and Feel of the Search Results Page - "
  end

  def how_it_works
    @title = "How the Affiliate Program Works - "
  end

  def demo
    @title = "See the Affiliate Program in Action - "
    if params.include?(:all)
      @affiliate_ads = AFFILIATE_ADS
    else
      @affiliate_ads = AFFILIATE_ADS.shuffle.slice(0,3)
    end
  end

  def new
    @title = "Add a New Site - "
    @user = @current_user
    @current_step = :edit_contact_information
  end

  def create
    @title = "Add a New Site - "
    @affiliate = Affiliate.new(params[:affiliate])
    @affiliate.users << @current_user
    if @affiliate.save
      @affiliate.update_attributes(
        :domains => @affiliate.staged_domains,
        :affiliate_template_id => @affiliate.staged_affiliate_template_id,
        :header => @affiliate.staged_header,
        :footer => @affiliate.staged_footer)
      @current_step = :get_the_code
      @affiliate.users.each do |user|
        Emailer.new_affiliate_site(@affiliate, user).deliver
      end
      flash.now[:success] = "Site successfully created"
    else
      @current_step = :new_site_information
    end
    render :action => :new
  end

  def update_site_information
    update
  end

  def update_look_and_feel
    update
  end

  def update
    if params[:commit] == "Make Live"
      if @affiliate.update_attributes_for_current(params[:affiliate])
        flash[:success]= "Updated changes to your live site successfully."
        redirect_to affiliate_path(@affiliate)
      else
        @title = UPDATE_ACTION_HASH[params[:action].to_sym][:title]
        render :action => UPDATE_ACTION_HASH[params[:action].to_sym][:edit_action]
      end
    else
      if @affiliate.update_attributes_for_staging(params[:affiliate])
        flash[:success]= "Staged changes to your site successfully."
        redirect_to affiliate_path(@affiliate)
      else
        @title = UPDATE_ACTION_HASH[params[:action].to_sym][:title]
        render :action => UPDATE_ACTION_HASH[params[:action].to_sym][:edit_action]
      end
    end
  end

  def update_contact_information
    @user = @current_user
    @user.strict_mode = true
    if @user.is_approved?
      update_contact_information_for_approved_user
    else
      update_contact_information_for_new_user
    end
  end

  def update_contact_information_for_approved_user
    @title = "Add a New Site - "
    if @user.update_attributes(params[:user])
      @affiliate = Affiliate.new
      @current_step = :new_site_information
    else
      @current_step = :edit_contact_information
    end
    render :action => :new
  end

  def update_contact_information_for_new_user
    if @user.update_attributes(params[:user])
      flash[:success] = 'Thank you for providing us your contact information. <br /> To continue the signup process, check your inbox, so we may verify your email address.'.html_safe
      redirect_to home_affiliates_path
    else
      render :action => :home
    end
  end

  def show
    @title = "Site: " + @affiliate.display_name + " - "
  end

  def preview
    @title = "Preview - "
  end

  def destroy
    @affiliate.destroy
    flash[:success]= "Site deleted"
    redirect_to home_affiliates_path
  end

  def push_content_for
    @affiliate.push_staged_changes
    flash[:success] = "Staged content is now visible"
    redirect_to affiliate_path(@affiliate)
  end

  def cancel_staged_changes_for
    @affiliate.cancel_staged_changes
    flash[:success] = "Staged changes were successfully cancelled."
    redirect_to affiliate_path(@affiliate)
  end

  def embed_code
    @title = "Embed Search Code - "
    @affiliate = Affiliate.find(params[:id])
  end

  def home
    @title = "Affiliate Center - "
    if params["said"].present?
      @affiliate = Affiliate.find(params["said"])
    end
    @user = @current_user if @current_user.is_pending_contact_information?
  end

  protected
  
  def sync_affiliate_staged_attributes
    @affiliate.sync_staged_attributes
  end
  
end
