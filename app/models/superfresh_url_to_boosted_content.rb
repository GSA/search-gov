class SuperfreshUrlToBoostedContent
  @queue = :usasearch
  TRUNCATED_TITLE_LENGTH = 60
  TRUNCATED_DESC_LENGTH = 250

  def self.perform(url, affiliate_id)
    return unless SuperfreshUrl.find_by_url_and_affiliate_id(url, affiliate_id)
    begin
      doc = Nokogiri::HTML(open(url))
      return unless (title = doc.xpath("//title").first.content.squish.truncate(TRUNCATED_TITLE_LENGTH,:separator=>" ") rescue nil)
      description = doc.xpath("//meta[translate(@name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz') = 'description' ] ").
        first.attributes["content"].value.squish rescue nil
      if description.nil?
        doc.xpath('//script').each { |x| x.remove }
        doc.xpath('//style').each { |x| x.remove }
        description = doc.inner_text.strip.gsub(/[\t\n\r]/, ' ').gsub(/(\s)\1+/, '. ').truncate(TRUNCATED_DESC_LENGTH, :separator => ' ')
      end
      boostedcontent = BoostedContent.create!(:url => url, :title=> title, :description => description, :affiliate_id => affiliate_id, :auto_generated => true)
      Sunspot.index!(boostedcontent)
    rescue Exception => e
      Rails.logger.error "Trouble fetching #{url} for boosted content creation: #{e}"
    end
  end
end