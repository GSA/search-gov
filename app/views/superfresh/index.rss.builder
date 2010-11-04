xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Search.USA.gov Superfresh Feed"
    xml.description "Recently updated URLs from around the US Government"
    xml.link 'http://search.usa.gov'

#    for post in @posts
#      xml.item do
#        xml.title post.title
#        xml.description post.content
#        xml.pubDate post.created_at.to_s(:rfc822)
#        xml.link post_url(post)
#      end
#    end
  end
end
