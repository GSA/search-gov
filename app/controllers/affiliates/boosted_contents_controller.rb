class Affiliates::BoostedContentsController < Affiliates::AffiliatesController
  before_filter :require_affiliate
  before_filter :setup_affiliate
  before_filter :find_boosted_content, :only => [:edit, :update, :destroy]

  MAX_TO_DISPLAY = 100
  NUMBER_TO_DISPLAY_IF_ABOVE_MAX = 10

  def new
    @title = "Boosted Content - "
    @boosted_content = @affiliate.boosted_contents.new
    load_boosted_contents
  end

  def edit
    @title = "#{@boosted_content.title} - Edit Boosted Content Entry"
  end

  def update
    if @boosted_content.update_attributes(params[:boosted_content])
      flash[:success] = "Boosted Content entry successfully updated"
      redirect_to new_affiliate_boosted_content_path
    else
      flash[:error] = "There was a problem saving your Boosted Content entry"
      render :action => :edit
    end
  end

  def create
    @boosted_content = BoostedContent.create(params[:boosted_content].merge(:affiliate => @affiliate))
    if @boosted_content.errors.empty?
      flash[:success] = "Boosted Content entry successfully added for affiliate '#{ERB::Util.html_escape(@affiliate.display_name)}'"
      redirect_to new_affiliate_boosted_content_path
    else
      flash[:error] = "There was a problem saving your Boosted Content entry"
      load_boosted_contents
      render :action => :new
    end
  end

  def destroy
    @boosted_content.destroy
    flash[:success] = "Boosted Content entry successfully deleted"
    redirect_to new_affiliate_boosted_content_path
  end

  def destroy_all
    @affiliate.boosted_contents.delete_all
    flash[:success] = "All Boosted Content successfully deleted"
    redirect_to new_affiliate_boosted_content_path
  end

  def bulk
    if (results = BoostedContent.process_boosted_content_xml_upload_for(@affiliate, params[:xml_file]))
      messages = []
      messages << "#{results[:created]} Boosted Content entries successfully created." if results[:created] > 0
      messages << "#{results[:updated]} Boosted Content entries successfully updated." if results[:updated] > 0
      flash[:success] = "Successful Bulk Import for affiliate '#{ERB::Util.html_escape(@affiliate.display_name)}':<br/>#{messages.join("<br/>")}"
    else
      flash[:error] = "Your XML document could not be processed. Please check the format and try again."
    end
    redirect_to new_affiliate_boosted_content_path
  end

  private
  def find_boosted_content
    @boosted_content = BoostedContent.find(params[:id])
  end

  def load_boosted_contents
    @boosted_content_count = @affiliate.boosted_contents.count
    @boosted_contents = @boosted_content_count > MAX_TO_DISPLAY ?
        @affiliate.boosted_contents.order("updated_at desc, id desc").limit(NUMBER_TO_DISPLAY_IF_ABOVE_MAX) :
        @affiliate.boosted_contents
  end

end
