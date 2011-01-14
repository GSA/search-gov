class Affiliates::HomeController < Affiliates::AffiliatesController
  before_filter :require_affiliate_or_admin, :except=> [:index, :edit, :how_it_works, :demo]
  before_filter :require_affiliate, :only => [:edit]
  before_filter :setup_affiliate, :only=> [:edit, :update, :show, :push_content_for, :destroy]

  def index
    @title = "Affiliate Program - "
  end

  def edit
  end

  def how_it_works
    @title = "How it works - "
  end

  def demo
    @title = "See it in Action - "
  end
   
  def new
    @affiliate = Affiliate.new
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
      flash[:success] = "Affiliate successfully created"
      redirect_to home_affiliates_path(:said=>@affiliate.id)
    else
      render :action => :new
    end
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

  def show
    @title = "Affiliate Page for " + @affiliate.name + " - "
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
