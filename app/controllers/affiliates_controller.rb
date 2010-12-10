class AffiliatesController < AffiliateAuthController
  before_filter :require_affiliate_or_admin, :except=> [:index, :edit, :how_it_works, :demo]
  before_filter :require_affiliate, :only => [:edit]
  before_filter :setup_affiliate, :only=> [:edit, :update, :show, :push_content_for, :destroy, :analytics, :query_search, :monthly_reports, :sayt_suggestions, :upload_sayt_suggestions]
  before_filter :establish_aws_connection, :only => [:analytics, :monthly_reports]

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

  def push_content_for
    @affiliate.update_attributes(
      :has_staged_content=> false,
      :domains => @affiliate.staged_domains,
      :header => @affiliate.staged_header,
      :footer => @affiliate.staged_footer)
    flash[:success] = "Staged content is now visible"
    redirect_to home_affiliates_path(:said=>@affiliate.id)
  end

  def embed_code
    @title = "Embed Search Code - "
    @affiliate = Affiliate.find(params[:id])
  end

  def analytics
    @title = "Query Logs - "
    @num_results_dqs = (request["num_results_dqs"] || "10").to_i
    @day_being_shown = request["day"].nil? ? DailyQueryStat.most_recent_populated_date(@affiliate.name) : request["day"].to_date
    @most_recent_day_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 1, @num_results_dqs, @affiliate.name)
    @trailing_week_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 7, @num_results_dqs, @affiliate.name)
    @trailing_month_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 30, @num_results_dqs, @affiliate.name)
    @start_date = 1.month.ago.to_date
    @end_date = Date.yesterday
  end

  def monthly_reports
    @title = "Monthly Reports - "
    @most_recent_date = DailyUsageStat.most_recent_populated_date(@affiliate.name) || Date.today
    @report_date = params[:date].blank? ? Date.yesterday : Date.civil(params[:date][:year].to_i, params[:date][:month].to_i)
    @monthly_totals = DailyUsageStat.monthly_totals(@report_date.year, @report_date.month, @affiliate.name)
  end

  def query_search
    @search_query_term = params["query"]
    @start_date = Date.parse(params["analytics_search_start_date"]) rescue 1.month.ago.to_date
    @end_date = Date.parse(params["analytics_search_end_date"]) rescue Date.yesterday
    @search_results = DailyQueryStat.query_counts_for_terms_like(@search_query_term, @start_date, @end_date, @affiliate.name)
  end
  
  def destroy
    @affiliate.destroy
    flash[:success]= "Affiliate deleted"
    redirect_to home_affiliates_path
  end

  def home
    @title = "Affiliate Dashboard - "
    if params["said"].present?
      @affiliate = Affiliate.find(params["said"])
    end
  end
end
