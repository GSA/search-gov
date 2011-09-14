class AgencyPopularUrl < ActiveRecord::Base
  validates_presence_of :agency_id, :title, :url, :source, :locale
  validates_uniqueness_of :url, :scope => :agency_id
  validates_inclusion_of :locale, :in => SUPPORTED_LOCALES, :message => 'must be selected'
  belongs_to :agency
  scope :with_locale, lambda { |locale| where(:locale => locale) }

  class << self
    def compute_for_date(date = Date.yesterday)
      bitly_api = BitlyAPI.new(:username => 'usagov', :password => '***REMOVED***', :api_key => 'R_8e9e6b912573a6c8b7bd013f1f4f68e6')
      csv_file = bitly_api.grab_csv_for_date(date)
      bitly_api.parse_csv(csv_file)
      AgencyPopularUrl.transaction do
        Agency.all.each do |agency|
          AgencyPopularUrl.destroy_all(["agency_id = ? AND source = ?", agency.id, 'bitly'])
          popular_links = bitly_api.get_popular_links_for_domain(agency.domain)
          popular_links.each do |link|
            agency.agency_popular_urls << AgencyPopularUrl.new(:url => link[:long_url], :title => link[:title], :rank => link[:clicks], :source => 'bitly', :locale => 'en')
          end
        end
      end
      PopularUrl.transaction do
        Affiliate.all.each do |affiliate|
          PopularUrl.destroy_all(["affiliate_id = ?", affiliate.id])
          popular_links = []
          affiliate.domains_as_array.each do |domain|
            popular_links += bitly_api.get_popular_links_for_domain(domain)
          end
          popular_links.each do |link|
            affiliate.popular_urls << PopularUrl.new(:url => link[:long_url], :title => link[:title], :rank => link[:clicks])
          end
        end
      end
    end
  end
end
