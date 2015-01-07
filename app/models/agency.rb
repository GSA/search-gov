class Agency < ActiveRecord::Base
  extend AttributeSquisher

  before_validation_squish :name, :organization_code,
                           assign_nil_on_blank: true
  validates_presence_of :name
  belongs_to :federal_register_agency
  has_many :agency_queries, :dependent => :destroy
  has_many :affiliates
  after_save :generate_agency_queries,
             :load_federal_register_documents

  NAME_QUERY_PREFIXES = ["the", "us", "u.s.", "united states"]
  SOCIAL_MEDIA_SERVICES = %w{Facebook Twitter YouTube Flickr}

  def friendly_name
    @friendly_name ||= begin
      friendly_name_str = name
      friendly_name_str << " FRA: #{federal_register_agency.to_label}" if federal_register_agency
      friendly_name_str << " JOBS: #{organization_code}" if organization_code.present?
      friendly_name_str
    end
  end

  private

  def generate_agency_queries
    self.agency_queries.destroy_all
    self.agency_queries << AgencyQuery.new(:phrase => self.name.downcase)
    NAME_QUERY_PREFIXES.each do |prefix|
      self.agency_queries << AgencyQuery.new(:phrase => "#{prefix} #{self.name.downcase}")
    end
    if self.abbreviation.present?
      self.agency_queries << AgencyQuery.new(:phrase => self.abbreviation)
      self.agency_queries << AgencyQuery.new(:phrase => "the #{self.abbreviation}")
    end
  end

  def load_federal_register_documents
    federal_register_agency.load_documents if federal_register_agency
  end
end
