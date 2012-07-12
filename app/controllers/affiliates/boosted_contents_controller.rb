class Affiliates::BoostedContentsController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate
  before_filter :find_boosted_content, :only => [:show, :edit, :update, :destroy]

  MAX_TO_DISPLAY = 100
  NUMBER_TO_DISPLAY_IF_ABOVE_MAX = 10

  def index
    @title = 'Best Bets: Text - '
    @boosted_contents = @affiliate.boosted_contents.paginate(:per_page => BoostedContent.per_page, :page => params[:page], :order => 'updated_at DESC, id DESC')
  end

  def new
    @title = "Add a new Best Bets: Text - "
    @boosted_content = @affiliate.boosted_contents.new(:publish_start_on => Date.current)
  end

  def edit
    @title = "Edit Best Bets: Text entry"
  end

  def update
    if @boosted_content.update_attributes(params[:boosted_content])
      index_boosted_content(@boosted_content)
      redirect_to [@affiliate, @boosted_content], :flash => { :success => 'Best Bets: Text entry successfully updated' }
    else
      @title = "Edit Best Bets: Text entry"
      render :action => :edit
    end
  end

  def create
    @boosted_content = @affiliate.boosted_contents.build(params[:boosted_content])
    if @boosted_content.save
      index_boosted_content(@boosted_content)
      redirect_to [@affiliate, @boosted_content], :flash => { :success => 'Best Bets: Text entry successfully added' }
    else
      @title = "Edit Best Bets: Text entry"
      render :action => :new
    end
  end

  def show
    @title = "Best Bets: Text - "
  end

  def destroy
    @boosted_content.destroy
    @boosted_content.solr_remove_from_index
    redirect_to affiliate_boosted_contents_path(@affiliate), :flash => { :success => "Best Bets: Text entry successfully deleted" }
  end

  def destroy_all
    @affiliate.boosted_contents.each do |bc|
      bc.delete
      bc.solr_remove_from_index
    end
    flash[:success] = "All Best Bets: Text entries successfully deleted"
    redirect_to affiliate_boosted_contents_path(@affiliate)
  end

  def bulk_new
    @title = "Bulk Upload Best Bets: Text - "
  end

  def bulk
    results = BoostedContent.process_boosted_content_bulk_upload_for(@affiliate, params[:bulk_upload_file])
    if (results[:success])
      messages = []
      messages << "#{results[:created]} Best Bets: Text entries successfully created." if results[:created] > 0
      messages << "#{results[:updated]} Best Bets: Text entries successfully updated." if results[:updated] > 0
      flash[:success] = "Successful Bulk Import for affiliate '#{ERB::Util.h(@affiliate.display_name)}':<br/>#{messages.join("<br/>")}".html_safe
      redirect_to affiliate_boosted_contents_path(@affiliate)
    else
      flash.now[:error] = results[:error_message]
      render :action => :bulk_new
    end
  end

  private

  def find_boosted_content
    @boosted_content = @affiliate.boosted_contents.find_by_id(params[:id])
    redirect_to affiliate_boosted_contents_path(@affiliate) unless @boosted_content
  end

  def index_boosted_content(boosted_content)
    Sunspot.index(boosted_content)
  end
end
