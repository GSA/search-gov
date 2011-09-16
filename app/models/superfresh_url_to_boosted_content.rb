class SuperfreshUrlToBoostedContent
  @queue = :usasearch
  TRUNCATED_TITLE_LENGTH = 60
  TRUNCATED_DESC_LENGTH = 250

  def self.perform(url, affiliate_id)
    return unless SuperfreshUrl.find_by_url_and_affiliate_id(url, affiliate_id)
    begin
      if PdfDocument.is_pdf?(url)
        pdf_document = PdfDocument.crawl_pdf(url)
        if pdf_document and pdf_document.is_a?(PdfDocument)
          pdf_document.affiliate_id = affiliate_id
          pdf_document.save!
        end
      else
        boosted_content = crawl_html(url)
        if boosted_content and boosted_content.is_a?(BoostedContent)
          boosted_content.affiliate_id = affiliate_id
          boosted_content.save!
          Sunspot.index!(boosted_content)
        end
      end
    rescue Exception => e
      Rails.logger.error "Trouble fetching #{url} for boosted content creation: #{e}"
    end
  end
  
  def self.crawl_html(url)
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
        BoostedContent.new(:url => url, :title=> title, :description => description, :auto_generated => true, :locale => 'en', :status => 'active', :publish_start_on => Date.current)
    rescue Exception => e
      Rails.logger.error "Trouble fetching #{url} for boosted content creation: #{e}"
    end
  end
end