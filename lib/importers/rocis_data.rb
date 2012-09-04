class RocisData
  def initialize(rocis_data_csv_path = "#{Rails.root}/tmp/forms/rocis_data.csv")
    @rocis_data_csv_path = rocis_data_csv_path
  end

  def to_hash
    @rocis_hash ||= parse_rocis_csv
  end

  def parse_rocis_csv
    hash = {}
    CSV.parse(File.open(@rocis_data_csv_path, 'r:ISO-8859-1').read, :headers => true) do |row|
      parent_agency_acronym = row['ParentAgencyAcronym']
      agency_acronym = row['AgencyAcronym']
      agency_name = row['AgencyName']
      form_number = row['FormNumber']
      form_number = form_number.gsub(/\bform\b/i, '').strip.squish if form_number.present?

      case "#{parent_agency_acronym}/#{agency_acronym}"
      when 'GSA/GSA'
        normalize_gsa_form_number(form_number)
      when 'DOD/DODDEP'
        normalize_dod_form_number(form_number)
      end

      expiration_date = Date.strptime(row['ExpirationDate'], '%m/%d/%y') rescue nil
      form_abstract = Sanitize.clean(row['Abstract'].to_s).squish
      form_line_of_business = Sanitize.clean(row['LineOfBusiness'].to_s).squish
      form_subfunction = Sanitize.clean(row['Subfunction'].to_s).squish
      form_public_code = Sanitize.clean(row['PublicCode'].to_s).squish

      hash["#{parent_agency_acronym}/#{agency_acronym}"] ||= {
          :agency_name => agency_name,
          :forms => {} }
      hash["#{parent_agency_acronym}/#{agency_acronym}"][:forms][form_number] = {
          :expiration_date => expiration_date,
          :abstract => form_abstract,
          :line_of_business => form_line_of_business,
          :subfunction => form_subfunction,
          :public_code => form_public_code }
    end
    hash.freeze
  end

  private

  def normalize_dod_form_number(form_number)
    form_number.gsub!(/\s/, '-')
    form_number
  end

  def normalize_gsa_form_number(form_number)
    form_number.gsub!(/(\s+)/, '')
    form_number.sub!(/\-/, '') if form_number =~ /\A[[:alpha:]]+\-/
    form_number
  end
end