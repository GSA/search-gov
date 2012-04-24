class Affiliates::HomeController < Affiliates::AffiliatesController
  before_filter :require_affiliate_or_admin, :only => [:home, :urls_and_sitemaps]
  before_filter :require_affiliate, :except => [:index, :home, :urls_and_sitemaps]
  before_filter :require_approved_user, :except => [:index, :home, :update_contact_information]
  before_filter :setup_affiliate, :except => [:index, :new, :create, :update_contact_information, :home, :new_site_domain_fields, :new_sitemap_fields, :new_rss_feed_fields, :new_managed_header_link_fields, :new_managed_footer_link_fields, :new_youtube_handle_fields]
  before_filter :sync_affiliate_staged_attributes, :only => [:edit_site_information, :edit_look_and_feel, :edit_header_footer]
  before_filter :setup_for_results_modules_actions, :only => [:edit_results_modules, :new_connection_fields]

  UPDATE_ACTION_HASH = {
    :update_site_information => {
      :title => 'Site Information - ',
      :edit_action => :edit_site_information },
    :update_look_and_feel => {
      :title => "Look and Feel of the Search Results Page - ",
      :edit_action => :edit_look_and_feel },
    :update_header_footer => {
        :edit_action => :edit_header_footer },
    :update_social_media => {
      :title => "Social Media - ",
      :edit_action => :edit_social_media },
    :update_sidebar => {
        :edit_action => :edit_sidebar },
    :update_results_modules => {
        :edit_action => :edit_results_modules },
    :update_external_tracking => {
      :edit_action => :edit_external_tracking }
  }

  RESULTS_MODULES_ACTIONS = %w(edit_results_modules update_results_modules new_connection_fields)

  def index
    redirect_to(home_affiliates_path)
  end

  def edit_site_information
    @title = "Site Information - "
  end

  def edit_look_and_feel
    @title = "Look and Feel of the Search Results Page - "
  end

  def edit_header_footer
    setup_affiliate_for_editing
  end

  def new
    @title = "Add a New Site - "
    @current_step = :basic_settings
    @affiliate = Affiliate.new
  end

  def create
    @affiliate = Affiliate.new(params[:affiliate])
    @affiliate.users << @current_user
    if @affiliate.save
      @affiliate.push_staged_changes
      @affiliate.users.each do |user|
        Emailer.new_affiliate_site(@affiliate, user).deliver
      end
      redirect_to content_sources_affiliate_path(@affiliate)
    else
      @current_step = :basic_settings
      render :action => :new
    end
  end

  def content_sources
    @title = "Add a New Site - "
    @current_step = :content_sources
  end

  def create_content_sources
    if @affiliate.update_attributes(params[:affiliate])
      redirect_to get_the_code_affiliate_path(@affiliate)
    else
      @current_step = :content_sources
      render :action => :content_sources
    end
  end

  def get_the_code
    @title = "Add a New Site - "
    @current_step = :get_the_code
    render :action => :new
  end

  def update_site_information
    update
  end

  def update_look_and_feel
    update
  end

  def update_header_footer
    update
  end

  def update_social_media
    update
  end

  def update
    if params[:commit] == "Save"
      if @affiliate.update_attributes(params[:affiliate])
        redirect_to @affiliate, :flash => { :success => 'Site was successfully updated.' }
      else
        setup_affiliate_for_editing
        set_title_and_render_with_action
      end
    elsif params[:commit] == "Make Live"
      if @affiliate.update_attributes_for_live(params[:affiliate])
        Emailer.affiliate_header_footer_change(@affiliate).deliver if @affiliate.has_changed_header_or_footer
        redirect_to @affiliate, :flash => { :success => "Updated changes to your live site successfully." }
      else
        setup_affiliate_for_editing
        set_title_and_render_with_action
      end
    else
      if @affiliate.update_attributes_for_staging(params[:affiliate])
        redirect_to @affiliate, :flash => { :success => "Staged changes to your site successfully." }
      else
        setup_affiliate_for_editing
        set_title_and_render_with_action
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
      @affiliate.site_domains.build
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
    Emailer.affiliate_header_footer_change(@affiliate).deliver if @affiliate.has_changed_header_or_footer
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
  end

  def home
    if params["said"].present?
      @affiliate = Affiliate.find(params["said"])
    end
    @user = @current_user if @current_user.is_pending_contact_information?
  end

  def best_bets
    @title = "Best Bets - "
    @featured_collections = @affiliate.featured_collections.recent
    @boosted_contents = @affiliate.boosted_contents.recent
  end

  def edit_social_media
    @title = "Social Media - "
  end

  def urls_and_sitemaps
    @title = "URLs & Sitemaps - "
    @sitemaps = @affiliate.sitemaps.paginate(:all, :per_page => 5, :page => 1)
    @uncrawled_urls = IndexedDocument.uncrawled_urls(@affiliate, 1, 5)
    @crawled_urls = IndexedDocument.crawled_urls(@affiliate, 1, 5)
  end

  def hosted_sitemaps
    @title = "Hosted Sitemaps - "
  end

  def new_site_domain_fields
  end

  def new_sitemap_fields
  end

  def new_rss_feed_fields
  end

  def new_managed_header_link_fields
  end

  def edit_sidebar
  end

  def update_sidebar
    update
  end

  def edit_results_modules
  end

  def update_results_modules
    update
  end

  def edit_external_tracking
  end

  def update_external_tracking
    update
  end

  def new_connection_fields
  end

  def new_youtube_handle_fields
  end

  protected

  def sync_affiliate_staged_attributes
    @affiliate.sync_staged_attributes
  end

  def set_title_and_render_with_action
    @title = UPDATE_ACTION_HASH[params[:action].to_sym][:title]
    render :action => UPDATE_ACTION_HASH[params[:action].to_sym][:edit_action]
  end

  def setup_affiliate_for_editing
    setup_for_results_modules_actions if RESULTS_MODULES_ACTIONS.include?(params[:action])
    @affiliate.staged_managed_header_links = [] if @affiliate.staged_managed_header_links.nil?
    @affiliate.staged_managed_header_links = [{ "0" => {} }, { "1" => {} }] if @affiliate.staged_managed_header_links.blank?
    @affiliate.staged_managed_footer_links = [] if @affiliate.staged_managed_footer_links.nil?
    @affiliate.staged_managed_footer_links = [{ "0" => {} }, { "1" => {} }] if @affiliate.staged_managed_footer_links.blank?
  end

  def setup_for_results_modules_actions
    @available_affiliates = current_user.affiliates.where("id <> ?", @affiliate.id).collect { |a| [a.display_name, a.id] }
    @affiliate.connections.build if @affiliate.connections.blank?
  end
end
