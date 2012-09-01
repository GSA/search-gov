class FormImporter
  def initialize(options = {})
    @rocis_hash = options[:rocis_hash]
    @agency = options[:agency]
    @agency_sub_agency = options[:agency_sub_agency]
    @agency_locale = options[:agency_locale]
    @agency_display_name = options[:agency_display_name]
  end

  protected

  def import
    display_name = "#{@rocis_hash[@agency_sub_agency][:agency_name]}" if @rocis_hash[@agency_sub_agency]
    display_name ||= "#{@agency_display_name}"
    @form_agency = FormAgency.where(:name => @agency, :locale => @agency_locale).first_or_initialize
    @form_agency.display_name = display_name
    @form_agency.save!
    new_or_updated_forms = []
    Form.transaction do
      yield new_or_updated_forms
    end
    @form_agency.forms = new_or_updated_forms unless new_or_updated_forms.empty?
    lookup_matching_indexed_documents(@form_agency.forms)
  end

  def populate_rocis_fields(form)
    if rocis_forms_hash[form.number]
      form.abstract = rocis_forms_hash[form.number][:abstract]
      form.expiration_date = rocis_forms_hash[form.number][:expiration_date]
      form.line_of_business = rocis_forms_hash[form.number][:line_of_business]
      form.subfunction = rocis_forms_hash[form.number][:subfunction]
      form.public_code = rocis_forms_hash[form.number][:public_code]
    end

    if form.new_record? and rocis_forms_hash[form.number].nil?
      form.govbox_enabled = false if lookup_rocis_form_across_agency(form.number).present?
    end
  end

  def rocis_forms_hash
    @rocis_hash[@agency_sub_agency][:forms]
  end

  def lookup_rocis_form_across_agency(form_number)
    @rocis_hash.keys.each do |k|
      return @rocis_hash[k][:forms][form_number] if @rocis_hash[k][:forms][form_number]
    end
    nil
  end

  def lookup_matching_indexed_documents(forms)
    affiliate = Affiliate.find_by_name('usagov')
    return unless affiliate

    dc = affiliate.document_collections.all.find do |coll|
      coll.url_prefixes.count == 1 and coll.url_prefixes.where(:prefix => 'http://answers.usa.gov')
    end
    return unless dc

    forms.each do |f|
      odies = IndexedDocument.search_for(f.number, affiliate, dc, 1, 2)
      if odies and odies.results.present?
        f.indexed_documents = odies.results
      else
        f.indexed_documents = []
      end
    end
  end
end
