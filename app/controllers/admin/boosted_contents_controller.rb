class Admin::BoostedContentsController < Admin::AdminController
  before_filter :setup_boosted_content, :only => [:show, :edit, :update, :destroy]
  before_filter :setup_parent_page_title, :only => [:new, :create, :show, :edit, :update, :bulk_new, :bulk]

  def index
    @page_title = 'Search.USA.gov Best Bets: Text'
    @boosted_contents = BoostedContent.where(:affiliate_id => nil).paginate(:per_page => BoostedContent.per_page,
                                                                            :page => params[:page],
                                                                            :order => 'updated_at DESC, id DESC')
  end

  def new
    @page_title = 'Add a new Best Bets: Text'
    @boosted_content = BoostedContent.new(:publish_start_on => Date.current)
  end

  def create
    @boosted_content = BoostedContent.new(params[:boosted_content])
     if @boosted_content.save
       @page_title = 'Best Bets: Text entry'
       Sunspot.index(@boosted_content)
      redirect_to [:admin, @boosted_content], :flash => { :success => 'Best Bets: Text entry successfully added.' }
    else
      @page_title = 'Add a new Best Bets: Text'
      render :action => :new
    end
  end

  def show
    @page_title = 'Best Bets: Text entry'
  end

  def edit
    @page_title = 'Edit Best Bets: Text entry'
  end

  def update
    if @boosted_content.update_attributes(params[:boosted_content])
      Sunspot.index(@boosted_content)
      redirect_to [:admin, @boosted_content], :flash => { :success => 'Best Bets: Text entry successfully updated.' }
    else
      @page_title = 'Edit Best Bets: Text entry'
      render :action => :edit
    end
  end

  def destroy
    @boosted_content.destroy
    @boosted_content.solr_remove_from_index
    redirect_to admin_boosted_contents_path, :flash => { :success => 'Best Bets: Text entry successfully deleted' }
  end

  def bulk_new
    @page_title = 'Bulk Upload Best Bets: Text'
  end

  def bulk
    results = BoostedContent.process_boosted_content_bulk_upload_for(nil, params[:bulk_upload_file])
    if (results[:success])
      messages = []
      messages << "#{results[:created]} Best Bets: Text entries successfully created." if results[:created] > 0
      messages << "#{results[:updated]} Best Bets: Text entries successfully updated." if results[:updated] > 0
      flash[:success] = "Successful Bulk Import:<br/>#{messages.join("<br/>")}".html_safe
      redirect_to admin_boosted_contents_path
    else
      @page_title = 'Bulk Upload Best Bets: Text'
      flash.now[:error] = results[:error_message]
      render :action => :bulk_new
    end
  end

  private
  def setup_boosted_content
    @boosted_content = BoostedContent.where(:id => params[:id], :affiliate_id => nil).first
    redirect_to admin_boosted_contents_path unless @boosted_content
  end

  def setup_parent_page_title
    @parent_page_title = "Search.USA.gov Best Bets: Text"
  end
end
