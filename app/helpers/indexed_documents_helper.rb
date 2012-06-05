module IndexedDocumentsHelper
  def render_last_crawl_status(indexed_document)
    return indexed_document.last_crawl_status if indexed_document.last_crawl_status == IndexedDocument::OK_STATUS or indexed_document.last_crawl_status.blank?

    dialog_id = "crawled_url_error_#{indexed_document.id}"
    render_last_crawl_status_dialog(dialog_id, indexed_document.url, indexed_document.last_crawl_status).html_safe
  end
end
