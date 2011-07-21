class SuperfreshUrlToBoostedContent
  @queue = :usasearch

  def self.perform(url, affiliate_id)
    return unless SuperfreshUrl.find_by_url_and_affiliate_id(url, affiliate_id)
    begin
      doc = Nokogiri::HTML(open(url))
      title = doc.xpath("//title").first.content.squish.strip rescue nil
      return if title.nil?
      description = doc.xpath("//meta[translate(@name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = 'description' ] ").
        first.attributes["content"].value.squish.strip rescue nil
      if description.nil?
        doc.xpath('//script').each { |x| x.remove }
        doc.xpath('//style').each { |x| x.remove }
        description = doc.inner_text.strip.gsub(/[\t\n\r]/, ' ').gsub(/(\s)\1+/, '. ').truncate(250, :separator => ' ')
      end
      boostedcontent = BoostedContent.create!(:url => url, :title=> title, :description => description, :affiliate_id => affiliate_id, :auto_generated => true)
      Sunspot.index!(boostedcontent)
    rescue Exception => e
      Rails.logger.error "Trouble fetching #{url} for boosted content creation: #{e}"
    end
  end
end