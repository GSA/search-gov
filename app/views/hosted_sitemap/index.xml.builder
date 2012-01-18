if @num_pages
  xml.instruct!
  xml.sitemapindex("xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9") do
    @num_pages.times do |page|
      xml.sitemap { xml.loc(hosted_sitemap_url(@indexed_domain.id, :page => page + 1, :protocol => 'http'))}
    end
  end
end