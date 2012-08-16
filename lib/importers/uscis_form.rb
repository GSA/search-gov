class UscisForm
  BASE_URL = 'http://www.uscis.gov'.freeze
  AGENCY = 'uscis.gov'.freeze

  def self.import
    forms_index_url = retrieve_forms_index_url
    form_agency = FormAgency.where(:name => 'uscis.gov', :locale => :en).first_or_create! do |fa|
      fa.display_name = 'U.S. Citizenship and Immigration Services'
    end

    doc = Nokogiri::HTML(open(forms_index_url).read)
    new_or_updated_forms = []
    Form.transaction do
      doc.css('#foiaAD-detail tbody tr').each do |row|
        imported_form = import_form(form_agency, row)
        new_or_updated_forms << imported_form if imported_form
      end
    end
    form_agency.forms = new_or_updated_forms unless new_or_updated_forms.empty?
  end

  def self.retrieve_forms_index_url
    forms_index_url = nil
    doc = Nokogiri::HTML(open('http://www.uscis.gov/portal/site/uscis'))
    urls = doc.xpath(%q{//*[@id='topNav']//a[text()='FORMS']/@href}).select { |u| u.content.present? }
    forms_index_url = "#{BASE_URL}#{urls.first}" unless urls.empty?
    forms_index_url
  end

  private

  def self.import_form(form_agency, row)
    columns = row.css('td')

    title_link = columns[0].css('a').first
    form_title = Sanitize.clean(title_link.content.to_s.squish)
    form_number = Sanitize.clean(columns[1].content.to_s.squish)
    landing_page_path = title_link.attr(:href).to_s.strip

    form = form_agency.forms.where(:number => form_number).first_or_initialize
    form.title = form_title
    parse_revision_date(form, columns[3])
    if landing_page_path.present?
      landing_page_url = "#{BASE_URL}#{landing_page_path}"
      form.landing_page_url = landing_page_url
      parse_landing_page(form)
    end
    form.save!
    form
  end

  def self.parse_revision_date(form, revision_date_column)
    if revision_date_column
      sanitized_content = Sanitize.clean(revision_date_column.content.to_s.squish)
      form.revision_date = case sanitized_content
                           when %r[\A\d{1,2}/\d{1,2}/\d{2,4}]
                             sanitized_content.slice(%r[\A\d{1,2}/\d{1,2}/\d{2,4}])
                           when %r[\A\d{2}/\d{2}\Z]
                             sanitized_content.slice(%r[\A\d{2}/\d{2}\Z])
                           when %r[\A\b[[:alpha:]]+\b\s+\d{4}]
                             sanitized_content.slice(%r[\A\b[[:alpha:]]+\b\s+\d{4}])
                           end
    end
  end

  def self.parse_landing_page(form)
    doc = Nokogiri::HTML(open(form.landing_page_url).read)
    download_list_item= doc.css('#mainContent #bodyFormatting ul li').first
    if download_list_item
      form_path = download_list_item.css('a').first.attr(:href).to_s.strip
      form.url = "#{BASE_URL}#{form_path}" if form_path.present?
      download_list_item.css('a').remove
      download_size_and_file_type = Sanitize.clean(download_list_item.content.to_s.squish)
      download_size_and_file_type.gsub!(/(\(|\))/, '')
      form.file_size, form.file_type = download_size_and_file_type.split(' ')
    end

    dl_item = doc.css('#mainContent #bodyFormatting dl').first
    if dl_item and dl_item.children.present?
      dts = dl_item.xpath('./dt')
      dds = dl_item.xpath('./dd')
      parse_description(form, dts[0], dds[0])
      parse_number_of_pages(form, dts[1], dds[1])
      parse_short_url(form, dl_item.xpath('.//p'))
    end
  end

  def self.parse_description(form, dt, dd)
    if dt and dd and Sanitize.clean(dt.content.to_s.squish) =~ /\APurpose of Form/i
      form.description = Sanitize.clean(dd.content.to_s.squish)
    end
  end

  def self.parse_number_of_pages(form, dt, dd)
    if dt and dd and Sanitize.clean(dt.content.to_s.squish) =~ /\ANumber of Pages/i
      sanitized_content = Sanitize.clean(dd.content.to_s.squish)
      form.number_of_pages = case sanitized_content
                             when %r[\A\d+]
                               sanitized_content.slice(%r[\A\d+]).to_i
                             when %r[\bForm\b:?\s\d+]i
                               sanitized_content.slice(%r[\bForm\b:?\s\d+]i).split[1].to_i
                             when %r[\bInstructions\b:?\s\d+]i
                               sanitized_content.slice(%r[\bInstructions\b:?\s\d+]i).split[1].to_i
                             end
    end
  end

  def self.parse_short_url(form, paragraphs)
    if paragraphs
      paragraphs.each do |p|
        sanitized_content = Sanitize.clean(p.content.to_s.squish)
        if sanitized_content =~ /This page can be found at/i
          short_url = sanitized_content.slice(%r[http://.+]).to_s.strip
          form.landing_page_url = short_url unless short_url.blank?
        end
      end
    end
  end
end