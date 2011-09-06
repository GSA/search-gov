require 'pdf/toolkit'

class SuperfreshUrlToBoostedContent
  @queue = :usasearch
  TRUNCATED_TITLE_LENGTH = 60
  TRUNCATED_DESC_LENGTH = 250

  def self.perform(url, affiliate_id)
    return unless SuperfreshUrl.find_by_url_and_affiliate_id(url, affiliate_id)
    begin
      if is_pdf?(url)
        boosted_content = crawl_pdf(url)
      else
        boosted_content = crawl_html(url)
      end
      if boosted_content and boosted_content.is_a?(BoostedContent)
        boosted_content.affiliate_id = affiliate_id
        boosted_content.save!
        Sunspot.index!(boosted_content)
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
        BoostedContent.new(:url => url, :title=> title, :description => description, :auto_generated => true)
    rescue Exception => e
      Rails.logger.error "Trouble fetching #{url} for boosted content creation: #{e}"
    end
  end
  
  def self.crawl_pdf(url)
    begin
      pdf_io = open(url)
      pdf = PDF::Toolkit.open(pdf_io)
      puts pdf.inspect
      puts pdf.title
      puts pdf.to_text.read
      BoostedContent.new(:url => url, :title => title_from_pdf(pdf, url), :description => pdf.to_text.read, :auto_generated => true)    
    rescue Exception => e
      Rails.logger.error "Trouble fetching #{url} for boosted content creation: #{e}"
    end
  end
  
  def self.title_from_pdf(pdf, url)
    return pdf.title unless pdf.title.blank?
    begin
      body = pdf.to_text.read
      first_linebreak_index = body.strip.index("\n") || body.size
      first_sentence_index = body.strip.index(".")
      end_index = [first_linebreak_index, first_sentence_index].min - 1
      return body.strip[0..end_index]
    rescue
      return URI.decode(url[url.rindex("/") + 1..-1])
    end
  end
  
  def self.is_pdf?(url)
    url.ends_with(".pdf").present?
  end
end