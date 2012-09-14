class VaForm < FormImporter
  FORMS_HOME_PAGE_URL = 'http://www.va.gov/vaforms/'.freeze
  BASE_URL = 'http://www.va.gov'.freeze
  AGENCY_SUB_AGENCY = 'VA/VA'.freeze
  AGENCY = 'va.gov'.freeze
  AGENCY_DISPLAY_NAME = 'Department of Veterans Affairs'.freeze

  def initialize(rocis_hash)
    super({ :rocis_hash => rocis_hash,
            :agency => AGENCY,
            :agency_sub_agency => AGENCY_SUB_AGENCY,
            :agency_locale => :en,
            :agency_display_name => AGENCY_DISPLAY_NAME })
  end

  def import
    super do |new_or_updated_forms|
      @form_numbers = %w(10-1010EZ)
      form_index_page_urls.each do |url|
        doc = Nokogiri::HTML(open(url).read)
        rows = doc.xpath(%q{//*[@id='content-wrapper']//table[1]/tr[3]//table[1]//tr})
        rows.each do |row|
          form = import_form(row)
          if form
            new_or_updated_forms << form
            @form_numbers << form.number
          end
        end
      end
    end
  end

  def form_index_page_urls
    doc = Nokogiri::HTML(open(FORMS_HOME_PAGE_URL).read)
    urls = [FORMS_HOME_PAGE_URL]
    pagination_data = doc.xpath(%q{//*[@id='content-wrapper']//td[@colspan='5' and starts-with(text(), 'Page >>')]}).first
    pagination_data.xpath(%q{.//a/@href}).each { |link| urls << "#{BASE_URL}#{link}" }
    urls
  end

  def import_form(row)
    tds = row.xpath('./td')
    return unless tds.count == 5

    form_number_link = tds[0].css('a').first
    return unless form_number_link

    form_number = form_number_link.inner_text.squish
    form_number.gsub!(/^FL\s+/i, 'FL-')
    form_number.upcase!
    return unless form_number =~ /^[[:alnum:]]{2}\-[[:alnum:]]+/
    return if form_number =~ /^(OF|SF)/i or @form_numbers.include?(form_number)

    landing_page_path = form_number_link.attr(:href).to_s.strip
    landing_page_url = generate_absolute_url(landing_page_path)

    form_title = tds[1].inner_text.squish
    revision_date_string = tds[3].inner_text.squish
    revision_date = Date.parse(revision_date_string). strftime('%-m/%y') rescue revision_date_string
    number_of_pages_string = tds[4].inner_text.squish
    number_of_pages = number_of_pages_string if number_of_pages_string =~ /^[[:digit:]]+$/

    form = @form_agency.forms.where(:number => form_number).first_or_initialize
    form.details.clear
    form.title = form_title
    form.landing_page_url = landing_page_url
    form.revision_date = revision_date
    form.number_of_pages = number_of_pages

    form.url = landing_page_url
    form.file_type = 'PDF'

    fetch_form_links(form)
    if form.links.empty?
      form.verified = false
    end

    populate_rocis_fields(form)
    form.save!
    form
  end

  def fetch_form_links(form)
    form.links = []
    doc = Nokogiri::HTML(open(URI.escape(form.landing_page_url)).read)
    links = doc.xpath(%q{//*[@id='content-wrapper']//a[starts-with(text(), 'VA Form')]})
    links.each_with_index do |link, i|
      file_path = link.attr(:href).strip
      url = generate_absolute_url(file_path)
      next if url == 'http://www.vba.va.gov/pubs/forms/'
      file_type = lookup_format(url)
      if file_type == 'PDF'
        form.url = url
        form.links.insert(0, { :title => "Form #{form.number}",
                               :url => url,
                               :file_type => lookup_format(url),
                               :number_of_pages => form.number_of_pages })
      else
        form.links.insert(0, { :title => "Instruction for #{form.number}",
                               :file_type => lookup_format(url),
                               :url => url })
      end
    end
  end

  def generate_absolute_url(path)
    case path
    when %r{^/} then "#{BASE_URL}#{path}"
    when %r{^https?://} then path
    when %r{^\./} then "#{FORMS_HOME_PAGE_URL}#{path.slice(2..-1)}"
    else "#{FORMS_HOME_PAGE_URL}#{path}"
    end
  end
end
