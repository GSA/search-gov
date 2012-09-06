class GsaForm < FormImporter
  AGENCY_SUB_AGENCY = 'GSA/GSA'.freeze
  AGENCY = 'gsa.gov'.freeze
  AGENCY_DISPLAY_NAME = 'General Services Administration'.freeze
  BASE_URL = 'http://www.gsa.gov'.freeze

  def initialize(rocis_hash)
    super({ :rocis_hash => rocis_hash,
            :agency => AGENCY,
            :agency_sub_agency => AGENCY_SUB_AGENCY,
            :agency_locale => :en,
            :agency_display_name => AGENCY_DISPLAY_NAME })
  end

  def import
    super do |new_or_updated_forms|
      @form_numbers = []
      CSV.parse(File.read("#{Rails.root}/tmp/forms/gsa_forms.csv"), :headers => true) do |form_hash|
        form = import_form(form_hash)
        if form
          new_or_updated_forms << form
          @form_numbers << form.number
        end
      end
    end
  end

  private

  def import_form(form_hash)
    form_number = Sanitize.clean(form_hash['FORM NUMBER'].to_s).squish
    return if @form_numbers.include?(form_number)
    form_revision_date = Sanitize.clean(form_hash['REVISION DATE'].to_s).strip
    return unless form_revision_date =~ /\A\d{2}\/\d{4}\Z/ or form_revision_date.blank?

    form_title = Sanitize.clean(form_hash['TITLE'].to_s).squish
    form_landing_page_url = Sanitize.clean(form_hash['FORM URL'].to_s).strip
    form_file_size = form_hash['FILE SIZE'].to_s.strip

    form = @form_agency.forms.where(:number => form_number).first_or_initialize
    form.details.clear
    form.file_type = 'PDF'
    form.file_size = "#{form_file_size} KB" if form_file_size.present?
    form.title = form_title
    form.landing_page_url = form_landing_page_url
    form.revision_date = Date.strptime(form_revision_date, '%m/%Y').strftime('%-m/%y') if form_revision_date.present?

    populate_rocis_fields(form)
    form.links = scrape_links(form)
    if form.links.present?
      form.url = form.links.first[:url]
    else
      form.url = form.landing_page_url
      form.verified = false
    end

    form.save!
    form
  end

  def scrape_links(form)
    doc = Nokogiri::HTML(open(form.landing_page_url).read)
    downloadable_list = doc.css('#formsDownloads li strong') rescue nil
    links = []
    downloadable_list.each do |item|
      inner_text = item.inner_text.to_s.squish
      url = item.css('a').first.attr(:href).to_s.strip
      url = url.sub(/;jsessionid=[[:alnum:]]+\.?[[:alnum:]]+/i, '')
      absolute_url = "#{BASE_URL}#{url}"
      file_type = case inner_text
                  when /PDF Version\Z/i then 'PDF'
                  when /Microsoft Word Version\Z/i then 'DOC'
                  end
      if file_type.present?
        link = { :title => "Form #{form.number}", :url => absolute_url, :file_type => file_type }
        link[:file_size] = form.file_size if file_type == 'PDF'
        links << link
      end
    end
    links
  end
end
