class BoostedSite < ActiveRecord::Base
  require 'rexml/document'
  validates_presence_of :title, :url, :description, :affiliate
  belongs_to :affiliate

  searchable :auto_index => false do
    text :title, :description
    integer :affiliate_id
  end

  def self.search_for(affiliate, query)
    search do
      with :affiliate_id, affiliate.id
      keywords query, :highlight=>true
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
