class BoostedSite < ActiveRecord::Base
  require 'rexml/document'
  validates_presence_of :title, :url, :description, :locale
  validates_inclusion_of :locale, :in => SUPPORTED_LOCALES
  belongs_to :affiliate

  searchable :auto_index => false do
    text :title, :description
    string :affiliate_name do |boosted_site|
      if boosted_site.affiliate_id.nil?
        Affiliate::USAGOV_AFFILIATE_NAME
      elsif Affiliate.find_by_id(boosted_site.affiliate_id)
        boosted_site.affiliate.name
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

  def self.process_boosted_site_xml_upload_for(affiliate, xmlfile)
    begin
      doc=REXML::Document.new(xmlfile.read)
      models_to_index = []
      transaction do
        destroy_all("affiliate_id = #{affiliate.id}")
        doc.root.each_element('//entry') do |entry|
          models_to_index << create!( :url => entry.elements["url"].first.to_s,
                                      :title => entry.elements["title"].first.to_s,
                                      :description => entry.elements["description"].first.to_s,
                                      :affiliate => affiliate )
        end
      end
      Sunspot.index(models_to_index)
      return true
    rescue
      RAILS_DEFAULT_LOGGER.warn "Problem processing boosted site XML document: #{$!}"
      Sunspot.index(affiliate.boosted_sites)
    end
    false
  end
end
