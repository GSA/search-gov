class AffiliatesController < AffiliateAuthController
  before_filter :require_affiliate, :except=> [:index]
  before_filter :setup_affiliate, :only=> [:edit, :update, :push_content_for, :destroy, :analytics, :query_search, :monthly_reports]

  def index
  end

  def edit
  end

  def new
    @affiliate = Affiliate.new
  end

  def create
    @affiliate = Affiliate.new(params[:affiliate])
    @affiliate.user = @current_user
    if @affiliate.save
      @affiliate.update_attributes(
        :domains => @affiliate.staged_domains,
        :header => @affiliate.staged_header,
        :footer => @affiliate.staged_footer)
      flash[:success] = "Affiliate successfully created"
      redirect_to account_path
    else
      render :action => :new
    end
  end

  def update
    @affiliate.attributes = params[:affiliate]
    if @affiliate.save
      @affiliate.update_attribute(:has_staged_content, true)
      flash[:success]= "Staged changes to your affiliate successfully."
      redirect_to account_path
    else
      render :action => :edit
    end
  end

  def push_content_for
    @affiliate.update_attributes(
      :has_staged_content=> false,
      :domains => @affiliate.staged_domains,
      :header => @affiliate.staged_header,
      :footer => @affiliate.staged_footer)
    flash[:success] = "Staged content is now visible"
    redirect_to account_path
  end

  def embed_code
    @affiliate = Affiliate.find(params[:id])
  end
  
  def analytics
    @num_results_qas = (request["num_results_qas"] || "10").to_i
    @num_results_dqs = (request["num_results_dqs"] || "10").to_i
    @day_being_shown = request["day"].nil? ? DailyQueryStat.most_recent_populated_date(@affiliate.name) : request["day"].to_date
    @most_recent_day_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 1, @num_results_dqs, @affiliate.name)
    @trailing_week_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 7, @num_results_dqs, @affiliate.name)
    @trailing_month_popular_terms = DailyQueryStat.most_popular_terms(@day_being_shown, 30, @num_results_dqs, @affiliate.name)
  end
  
  def monthly_reports
    @today = Date.today
    @report_date = params[:date].blank? ? @today : Date.civil(params[:date][:year].to_i, params[:date][:month].to_i)
    @monthly_totals = DailyUsageStat.monthly_totals(@report_date.year, @report_date.month, @affiliate.name)
  end
  
  def query_search
    @search_query_term = params["query"]
    @search_results = []
    unless @search_query_term.blank?
      @starts_with = true
      @starts_with = false if params["search_type"] && params["search_type"] == "contains"
      @search_results = DailyQueryStat.most_popular_terms_like(@search_query_term, @starts_with, @affiliate.name)
    end
  end
  
  def destroy
    @affiliate.destroy
    flash[:success]= "Affiliate deleted"
    redirect_to account_path
  end

end
