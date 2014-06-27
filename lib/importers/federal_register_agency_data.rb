module FederalRegisterAgencyData
  def self.import
    agencies = FederalRegister::Agency.all
    current_agency_ids = FederalRegisterAgency.pluck :id

    loaded_agency_ids = load_agencies(agencies)
    obsolete_agency_ids = current_agency_ids - loaded_agency_ids
    FederalRegisterAgency.destroy obsolete_agency_ids if loaded_agency_ids.present?
    loaded_agency_ids.count
  end

  private

  def self.load_agencies(agencies)
    loaded_agency_ids = []
    agencies.each do |agency|
      fr_agency = FederalRegisterAgency.where(id: agency.id).first_or_initialize
      fr_agency.assign_attributes(name: agency.name, short_name: agency.short_name)
      loaded_agency_ids << fr_agency.id if fr_agency.save
    end
    loaded_agency_ids
  end
end
