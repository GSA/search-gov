class BoostedContent < ActiveRecord::Base
  require 'rexml/document'
  belongs_to :affiliate

  validates_presence_of :title, :url, :description, :locale
  validates_uniqueness_of :url, :message => "has already been boosted", :scope => "affiliate_id"
  validates_inclusion_of :locale, :in => SUPPORTED_LOCALES

  after_save :sunspot_index

  searchable :auto_index => false do
    text :title, :description
    text :keywords do
      keywords.split(',') unless keywords.nil?
    end
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
      fulltext query do
        highlight :title, :description, :max_snippets => 1, :fragment_size => 255, :merge_continuous_fragments => true
      end
      with(:affiliate_name, affiliate ? affiliate.name : Affiliate::USAGOV_AFFILIATE_NAME)
      with(:locale, locale.to_s) if locale
      paginate :page => 1, :per_page => 3
    end rescue nil
  end

  def self.process_boosted_content_xml_upload_for(affiliate, xml_file)
    existing = affiliate.boosted_contents.inject({}) do |hash, bc|
      hash[bc.url] = bc
      hash
    end

    counts = {:created => 0, :updated => 0}
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
          if matching = existing[info[:url]]
            matching.update_attributes(info)
            counts[:updated] += 1
          else
            create!(info)
            counts[:created] += 1
          end
        end
      end
    rescue
      RAILS_DEFAULT_LOGGER.warn "Problem processing boosted Content XML document: #{$!}"
      Sunspot.index(affiliate.boosted_contents)
      return false
    end
    counts
  end

  def sunspot_index
    Sunspot.index(self)
  end

  def as_json(options = {})
    {:title => title, :url => url, :description => description}
  end
end
