class SsaForm < FormImporter
  AGENCY_SUB_AGENCY = 'SSA/SSA'.freeze
  AGENCY = 'ssa.gov'.freeze
  AGENCY_DISPLAY_NAME = 'Social Security Administration'.freeze
  SSA_JSON_URL = 'http://www.socialsecurity.gov/online/forms.json'.freeze

  def initialize(rocis_hash)
    super({ :rocis_hash => rocis_hash,
            :agency => AGENCY,
            :agency_sub_agency => AGENCY_SUB_AGENCY,
            :agency_locale => :en,
            :agency_display_name => AGENCY_DISPLAY_NAME })
  end

  def import
    super do |new_or_updated_forms|
      forms = JSON.parse(open(SSA_JSON_URL).read) || []
      forms.each do |form|
        imported_form = import_form(form)
        new_or_updated_forms << imported_form if imported_form
      end
    end
  end

  private

  def import_form(form_hash)
    form_number = Sanitize.clean(form_hash['number'].to_s).squish
    return nil if form_number =~ /(\Aonline\Z|\-SP\Z)/i
    form_title = Sanitize.clean(form_hash['title'].to_s).squish
    form_url = Sanitize.clean(form_hash['link'].to_s).squish

    form = @form_agency.forms.where(:number => form_number).first_or_initialize
    form.details.clear
    form.file_type = 'PDF'
    form.title = form_title
    form.url = form_url

    if form.url =~ /\.html\Z/i
      form.landing_page_url = form.url
      form.url = form.url.gsub(/\.html\Z/i, '.pdf')
    end

    form.links = [{ :title => "Form #{form_number}", :url => form.url, :file_type => form.file_type }]
    populate_rocis_fields(form)
    form.save!
    form
  end
end
