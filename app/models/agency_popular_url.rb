class AgencyPopularUrl < ActiveRecord::Base
  validates_presence_of :agency_id, :title, :url, :source
  validates_uniqueness_of :url
  belongs_to :agency

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
            agency.agency_popular_urls << AgencyPopularUrl.new(:url => link[:long_url], :title => link[:title], :rank => link[:clicks], :source => 'bitly')
          end
        end
      end
    end
  end
end
