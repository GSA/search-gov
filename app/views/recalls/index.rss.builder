xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Search.USA.gov Recalls Feed"
    xml.description "Recent recalls from around the US Government"
    xml.link 'http://search.usa.gov/recalls'
    
    @latest_recalls.results.each do |recall|
      xml.item do
        xml.title recall.summary
        xml.description recall.description
        xml.link recall.recall_url
        xml.pubDate recall.recalled_on.to_s(:rfc822)
      end
    end
  end
end