class SsaForm
  AGENCY_SUB_AGENCY = 'SSA/SSA'.freeze
  AGENCY = 'ssa.gov'.freeze
  AGENCY_NAME = 'Social Security Administration'.freeze
  SSA_JSON_URL = 'http://www.socialsecurity.gov/online/forms.json'.freeze

  def initialize(rocis_hash)
    @rocis_hash = rocis_hash
  end

  def import
    display_name = "#{@rocis_hash[AGENCY_SUB_AGENCY][:agency_name]}" if @rocis_hash[AGENCY_SUB_AGENCY]
    display_name ||= "#{AGENCY_NAME}"
    form_agency = FormAgency.where(:name => AGENCY, :locale => :en).first_or_initialize
    form_agency.display_name = display_name
    form_agency.save!

    forms = JSON.parse(open(SSA_JSON_URL).read) || []
    new_or_updated_forms = []
    forms.each do |form|
      imported_form = import_form(form_agency, form)
      new_or_updated_forms << imported_form if imported_form
    end
    form_agency.forms = new_or_updated_forms unless new_or_updated_forms.empty?
    lookup_matching_indexed_documents(form_agency.forms)
  end

  private

  def import_form(form_agency, form)
    form_number = Sanitize.clean(form['number'].to_s).squish
    return nil if form_number =~ /(\Aonline\Z|\-SP\Z)/i
    form_title = Sanitize.clean(form['title'].to_s).squish
    form_url = Sanitize.clean(form['link'].to_s).squish

    form = form_agency.forms.where(:number => form_number).first_or_initialize
    form.file_type = 'PDF'
    form.title = form_title
    form.url = form_url

    if form.url =~ /\.html\Z/i
      form.landing_page_url = form.url
      form.url = form.url.gsub(/\.html\Z/i, '.pdf')
    end

    form.links = [{ :title => "Form #{form_number}", :url => form.url, :file_type => form.file_type }]
    if rocis_forms_hash[form_number]
      form.description = rocis_forms_hash[form_number][:description]
      form.expiration_date = rocis_forms_hash[form_number][:expiration_date]
    end

    if form.new_record? and rocis_forms_hash[form_number].nil?
      form.govbox_enabled = false if lookup_rocis_form_across_agency(form_number).present?
    end

    form.save!
    form
  end

  def rocis_forms_hash
    @rocis_hash[AGENCY_SUB_AGENCY][:forms]
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
