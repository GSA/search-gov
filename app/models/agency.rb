class Agency < ActiveRecord::Base
  validates_presence_of :name, :domain, :url
  validates_uniqueness_of :domain
  has_many :agency_queries, :dependent => :destroy
  after_save :generate_agency_queries
  
  NAME_QUERY_PREFIXES = ["the", "us", "u.s.", "united states"]
  
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
    self.agency_queries << AgencyQuery.new(:phrase => self.abbreviation) if self.abbreviation.present?
  end
end