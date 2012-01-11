if @indexed_documents
  xml.instruct!
  xml.urlset("xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9") do
    @indexed_documents.each do |indexed_document|
      xml.url { xml.loc(indexed_document.url)}
    end
  end
end