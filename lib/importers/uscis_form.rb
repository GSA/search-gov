class UscisForm
  BASE_URL = 'http://www.uscis.gov'.freeze
  AGENCY = 'uscis.gov'.freeze

  def self.import
    forms_index_url = retrieve_forms_index_url
    doc = Nokogiri::HTML(open(forms_index_url).read)
    existing_forms = Form.where(:agency => 'uscis.gov').select(:id).all
    new_or_updated_forms = []
    Form.transaction do
      doc.css('#foiaAD-detail tbody tr').each do |row|
        imported_form = import_form(row)
        new_or_updated_forms << imported_form if imported_form
      end
    end
    obsolete_forms = existing_forms - new_or_updated_forms
    obsolete_forms.each(&:destroy)
  end

  def self.retrieve_forms_index_url
    forms_index_url = nil
    doc = Nokogiri::HTML(open('http://www.uscis.gov/portal/site/uscis'))
    urls = doc.xpath(%q{//*[@id='topNav']//a[text()='FORMS']/@href}).select { |u| u.content.present? }
    forms_index_url = "#{BASE_URL}#{urls.first}" unless urls.empty?
    forms_index_url
  end

  private

  def self.import_form(row)
    columns = row.css('td')

    title_link = columns[0].css('a').first
    form_title = Sanitize.clean(title_link.content.to_s.squish)
    form_number = Sanitize.clean(columns[1].content.to_s.squish)
    landing_page_path = title_link.attr(:href).to_s.strip

    form = Form.where(:agency => AGENCY, :number => form_number).first_or_initialize
    form.title = form_title
    if landing_page_path.present?
      landing_page_url = "#{BASE_URL}#{landing_page_path}"
      form.landing_page_url = landing_page_url
      parse_landing_page(form)
    end
    form.save!
    form
  end

  def self.parse_landing_page(form)
    doc = Nokogiri::HTML(open(form.landing_page_url))
    download_list_item= doc.css('#mainContent #bodyFormatting ul li').first
    if download_list_item
      form_path = download_list_item.css('a').first.attr(:href).to_s.strip
      form.url = "#{BASE_URL}#{form_path}" if form_path.present?
      download_list_item.css('a').remove
      download_size_and_file_type = Sanitize.clean(download_list_item.content.to_s.squish)
      download_size_and_file_type.gsub!(/(\(|\))/, '')
      form.file_size, form.file_type = download_size_and_file_type.split(' ')
    end
  end
end