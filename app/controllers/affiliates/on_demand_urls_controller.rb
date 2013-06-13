class Affiliates::  OnDemandUrlsController < Affiliates::AffiliatesController
  EXPORT_CRAWLED_FIELDS = %w(url title description doctype last_crawled_at last_crawl_status)
  before_filter :require_affiliate_or_admin
  before_filter :setup_affiliate

  def crawled
    @title = 'Previously Crawled URLs - '
    @crawled_urls = IndexedDocument.crawled_urls(@affiliate, params[:page])
    respond_to do |format|
      format.html
    end
  end

  def uncrawled
    @title = 'Uncrawled URLs - '
    @uncrawled_urls = IndexedDocument.uncrawled_urls(@affiliate, params[:page])
  end

  def export_crawled
    respond_to do |format|
      format.csv {
        csv_data = CSV.generate do |csv|
          csv << EXPORT_CRAWLED_FIELDS
          @affiliate.indexed_documents.fetched.select(EXPORT_CRAWLED_FIELDS).paginate(:page => 1, :per_page => 10000).each do |doc|
            description = doc.description.nil? ? '' : doc.description.squish
            csv << [doc.url, doc.title, description, doc.doctype, doc.last_crawled_at, doc.last_crawl_status]
          end
        end
        send_data csv_data, :type => 'text/csv', :filename => "#{@affiliate.name}-crawled-urls.csv", :disposition => 'attachment'
      }
    end
  end

end
