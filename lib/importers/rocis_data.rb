class RocisData
  def initialize(rocis_data_csv_path = "#{Rails.root}/tmp/forms/rocis_data.csv")
    @rocis_data_csv_path = rocis_data_csv_path
  end

  def to_hash
    @rocis_hash ||= parse_rocis_csv
  end

  def parse_rocis_csv
    hash = {}
    CSV.parse(File.binread(@rocis_data_csv_path), :headers => true) do |row|
      parent_agency_acronym = row['ParentAgencyAcronym']
      agency_acronym = row['AgencyAcronym']
      agency_name = row['AgencyName']
      form_number = row['FormNumber']
      form_number = form_number.gsub(/\bform\b/i, '').strip.squish if form_number.present?
      expiration_date = Date.strptime(row['ExpirationDate'], '%m/%d/%y') rescue nil
      form_description = row['Abstract'].to_s.squish

      hash["#{parent_agency_acronym}/#{agency_acronym}"] ||= {
          :agency_name => agency_name,
          :forms => {} }
      hash["#{parent_agency_acronym}/#{agency_acronym}"][:forms][form_number] = {
          :expiration_date => expiration_date,
          :description => form_description }
    end
    hash.freeze
  end

end