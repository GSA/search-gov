module FederalRegisterAgencyData
  def self.import
    agency_hashes = FederalRegister::Agency.all.collect do |agency|
      agency.attributes.slice(* %w(id name parent_id short_name)).symbolize_keys
    end

    current_agency_ids = FederalRegisterAgency.pluck :id

    loaded_agency_ids = load_agencies(agency_hashes)
    obsolete_agency_ids = current_agency_ids - loaded_agency_ids
    FederalRegisterAgency.destroy obsolete_agency_ids if loaded_agency_ids.present?
    loaded_agency_ids.count
  end

  private

  def self.load_agencies(agency_hashes)
    loaded_agency_ids = []
    agency_hashes.each do |agency_hash|
      fr_agency = FederalRegisterAgency.where(id: agency_hash[:id]).first_or_initialize
      agency_hash[:name] &&= overwrite_name agency_hash[:short_name], agency_hash[:name]
      fr_agency.assign_attributes(agency_hash.except(:id))
      loaded_agency_ids << fr_agency.id if fr_agency.save
    end
    loaded_agency_ids
  end

  def self.overwrite_name(short_name, original_name)
    if short_name.present?
      agency = Agency.find_by_abbreviation short_name.squish
      return agency.name if agency
    end
    original_name
  end
end
