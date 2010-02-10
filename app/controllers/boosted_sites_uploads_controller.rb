class BoostedSitesUploadsController < AffiliateAuthController
  before_filter :require_affiliate
  before_filter :setup_affiliate

  def new
  end

  def create
    require 'rexml/document'
    file = params[:xmlfile]
    begin
      doc=REXML::Document.new(file.read)
      BoostedSite.transaction do
        BoostedSite.destroy_all("affiliate_id = #{@affiliate.id}")
        doc.root.each_element('//entry') do |entry|
          BoostedSite.create( :url => entry.elements["url"].first.to_s,
                              :title => entry.elements["title"].first.to_s,
                              :description => entry.elements["description"].first.to_s,
                              :affiliate => @affiliate )
        end
        flash[:success] = "Boosted sites uploaded successfully for #{@affiliate.name}"
        redirect_to account_path
      end
    rescue
      RAILS_DEFAULT_LOGGER.warn "Possible problem in processing : #{$!}"
      flash[:error] = "Your XML document could not be processed. Please check the format and try again."
      render :action => 'new'
    end
  end

end
