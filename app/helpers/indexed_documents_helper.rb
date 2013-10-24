module IndexedDocumentsHelper
  def indexed_document_class_hash(indexed_document)
    indexed_document.last_crawl_status_error? ? { class: 'error' } : {}
  end

  def indexed_document_last_crawl_status_error(indexed_document)
    return unless indexed_document.last_crawl_status_error?
    content_tag :div, id: "indexed-document-error-#{indexed_document.id}", class: 'collapse last-crawl-status' do
      indexed_document.last_crawl_status
    end
  end

  def indexed_document_source(source)
    case source
    when 'rss' then 'Feed'
    when 'manual' then 'Manual'
    end
  end

  def indexed_document_last_crawled_on(url)
    url.last_crawled_at.nil? ? 'Pending' : render_date(url.last_crawled_at)
  end

  def indexed_document_status(status)
    status == 'OK' ? status : status.humanize
  end

  def indexed_document_last_crawl_status(indexed_document)
    return indexed_document_status(indexed_document.last_crawl_status) unless indexed_document.last_crawl_status_error?
    link_to 'Error',
            "#indexed-document-error-#{indexed_document.id}",
            data: { toggle: 'collapse' }
  end
end
