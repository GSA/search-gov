class Agency < ActiveRecord::Base
  validates_presence_of :name, :domain
  validates_uniqueness_of :domain
  has_many :agency_queries, :dependent => :destroy
  has_many :agency_urls, :dependent => :destroy
  after_save :generate_agency_queries

  NAME_QUERY_PREFIXES = ["the", "us", "u.s.", "united states"]
  SOCIAL_MEDIA_SERVICES = %w{Facebook Twitter YouTube Flickr}

  def twitter_profile_link
    self.twitter_username.present? ? "http://twitter.com/#{self.twitter_username}" : nil
  end

  def facebook_profile_link
    self.facebook_username.present? ? "http://facebook.com/#{self.facebook_username}" : nil
  end

  def youtube_profile_link
    self.youtube_username.present? ? "http://youtube.com/#{self.youtube_username}" : nil
  end

  def flickr_profile_link
    self.flickr_url.present? ? self.flickr_url : nil
  end

  def has_phone_number?
    self.phone.present? or self.toll_free_phone.present? or self.tty_phone.present?
  end

  private

  def generate_agency_queries
    self.agency_queries.destroy_all
    self.agency_queries << AgencyQuery.new(:phrase => self.domain)
    self.agency_queries << AgencyQuery.new(:phrase => "www.#{self.domain}")
    self.agency_queries << AgencyQuery.new(:phrase => self.name.downcase)
    NAME_QUERY_PREFIXES.each do |prefix|
      self.agency_queries << AgencyQuery.new(:phrase => "#{prefix} #{self.name.downcase}")
    end
    self.name_variants.split(',').each do |name_variant|
      self.agency_queries << AgencyQuery.new(:phrase => name_variant.downcase.strip)
      NAME_QUERY_PREFIXES.each do |prefix|
        self.agency_queries << AgencyQuery.new(:phrase => "#{prefix} #{name_variant.downcase.strip}")
      end
    end unless self.name_variants.nil?
    if self.abbreviation.present?
      self.agency_queries << AgencyQuery.new(:phrase => self.abbreviation)
      self.agency_queries << AgencyQuery.new(:phrase => "the #{self.abbreviation}")
    end
  end
end