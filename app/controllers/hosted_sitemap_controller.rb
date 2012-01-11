class HostedSitemapController < ApplicationController
  before_filter :set_request_format
  MAX_URLS_PER_SITEMAP = 50000

  def show
    if (@indexed_domain = IndexedDomain.find(params[:id]) rescue nil)
      doc_count = @indexed_domain.indexed_documents.size
      @num_pages = (doc_count / max_urls_per_sitemap) + 1
      if doc_count > max_urls_per_sitemap and params[:page].blank?
        render :template => "hosted_sitemap/index"
      else
        page = (params[:page] || 1).to_i
        page = 1 unless page.between?(1,@num_pages)
        @indexed_documents = @indexed_domain.indexed_documents.select(:url).limit(max_urls_per_sitemap).offset((page - 1) * max_urls_per_sitemap)
      end
    end
  end

  private

  def default_url_options
    {}
  end

  def set_request_format
    request.format = :xml
  end

  def max_urls_per_sitemap
    MAX_URLS_PER_SITEMAP
  end
end
