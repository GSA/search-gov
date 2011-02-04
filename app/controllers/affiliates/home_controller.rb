class Affiliates::HomeController < Affiliates::AffiliatesController
  before_filter :require_affiliate_or_admin, :except=> [:index, :edit, :how_it_works, :demo]
  before_filter :require_affiliate, :only => [:edit]
  before_filter :setup_affiliate, :only=> [:edit, :update, :show, :push_content_for, :destroy]

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
  def index
    @title = "USASearch Affiliate Program - "
  end

  def edit
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
    @user = @current_user
    @current_step = :edit_contact_information
  end

  def create
    @affiliate = Affiliate.new(params[:affiliate])
    @affiliate.owner = @current_user
    if @affiliate.save
      @affiliate.update_attributes(
        :domains => @affiliate.staged_domains,
        :affiliate_template_id => @affiliate.staged_affiliate_template_id,
        :header => @affiliate.staged_header,
        :footer => @affiliate.staged_footer)
      @current_step = :get_the_code
      flash.now[:success] = "Site successfully created"
    else
      @current_step = :new_site_information
    end
    render :action => :new
  end

  def update
    @affiliate.attributes = params[:affiliate]
    if @affiliate.save
      @affiliate.update_attribute(:has_staged_content, true)
      flash[:success]= "Staged changes to your affiliate successfully."
      redirect_to home_affiliates_path(:said=>@affiliate.id)
    else
      render :action => :edit
    end
  end

  def update_contact_information
    @user = @current_user
    @user.strict_mode = true
    if @user.update_attributes(params[:user])
      @affiliate = Affiliate.new
      @current_step = :new_site_information
    else
      @current_step = :edit_contact_information
    end
    render :action => :new
  end

  def show
    @title = "Affiliate Page for " + @affiliate.display_name + " - "
  end
  
  def destroy
    @affiliate.destroy
    flash[:success]= "Affiliate deleted"
    redirect_to home_affiliates_path
  end

  def push_content_for
    @affiliate.update_attributes(
      :has_staged_content=> false,
      :domains => @affiliate.staged_domains,
      :affiliate_template_id => @affiliate.staged_affiliate_template_id,
      :header => @affiliate.staged_header,
      :footer => @affiliate.staged_footer)
    flash[:success] = "Staged content is now visible"
    redirect_to home_affiliates_path(:said=>@affiliate.id)
  end

  def embed_code
    @title = "Embed Search Code - "
    @affiliate = Affiliate.find(params[:id])
  end

  def home
    @title = "Affiliate Dashboard - "
    if params["said"].present?
      @affiliate = Affiliate.find(params["said"])
    end
  end
end
