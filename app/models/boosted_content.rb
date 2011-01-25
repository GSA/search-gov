class BoostedContent < ActiveRecord::Base
  require 'rexml/document'
  validates_presence_of :title, :url, :description, :locale
  validates_inclusion_of :locale, :in => SUPPORTED_LOCALES
  belongs_to :affiliate
  after_save :sunspot_index

  searchable :auto_index => false do
    text :title, :description
    string :affiliate_name do |boosted_content|
      if boosted_content.affiliate_id.nil?
        Affiliate::USAGOV_AFFILIATE_NAME
      elsif Affiliate.find_by_id(boosted_content.affiliate_id)
        boosted_content.affiliate.name
      else
        nil
      end
    end
    string :locale
  end

  def self.search_for(query, affiliate = nil, locale = I18n.default_locale)
    search do
      keywords query, :highlight => true
      with(:affiliate_name, affiliate ? affiliate.name : Affiliate::USAGOV_AFFILIATE_NAME)
      with(:locale, locale.to_s) if locale
      paginate :page => 1, :per_page => 3
    end rescue nil
  end

  def self.process_boosted_content_xml_upload_for(affiliate, xml_file)
    existing = affiliate.boosted_contents
    begin
      doc=REXML::Document.new(xml_file.read)
      transaction do
        doc.root.each_element('//entry') do |entry|
          info = {
            :url => entry.elements["url"].first.to_s,
            :title => entry.elements["title"].first.to_s,
            :description => entry.elements["description"].first.to_s,
            :affiliate => affiliate
          }
          if matching = existing.detect { |boosted_content| boosted_content.url == info[:url] }
            matching.update_attributes(info)
          else
            create!(info)
          end
        end
      end
      return true
    rescue
      RAILS_DEFAULT_LOGGER.warn "Problem processing boosted Content XML document: #{$!}"
      Sunspot.index(affiliate.boosted_contents)
    end
    false
  end

  def sunspot_index
    Sunspot.index(self)
  end
end
