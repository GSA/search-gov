xml.instruct! :xml, :version => "1.0"
xml.rss(:version => "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom") do
  xml.channel do
    xml.title "Search.USA.gov Recalls Feed"
    xml.description "Recent recalls from around the US Government"
    xml.link 'http://search.usa.gov/recalls'
    xml.atom(:link, "href" => "http://#{APP_URL}/recalls/index.xml", "rel" => "self", "type" => "application/rss+xml")
    
    @latest_recalls.results.each do |recall|
      xml.item do
        xml.title recall.summary
        xml.description recall.description
        xml.link recall.recall_url
        xml.pubDate recall.recalled_on_est.to_time.to_s(:rfc822)
        xml.guid recall.recall_url
      end
    end
  end
end