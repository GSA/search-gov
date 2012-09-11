class DodForm < FormImporter
  FORM_URLS = %w(0001-0499 0500-0999 1000-1499 1500-1999 2000-2499 2500-2999).
      map { |u| "http://www.dtic.mil/whs/directives/infomgt/forms/dd/ddforms#{u}.htm" }.freeze


  BASE_URL = 'http://www.dtic.mil'.freeze
  AGENCY_SUB_AGENCY = 'DOD/DODDEP'.freeze
  AGENCY = 'defense.gov'.freeze
  AGENCY_DISPLAY_NAME = 'U.S. Department of Defense'.freeze
  URLS_WITH_404 = %w(http://www.dtic.mil/whs/directives/infomgt/forms/issuance.htm http://www.transcom.mil/j5/pt/dtr.cfm)

  def initialize(rocis_hash)
    super({ :rocis_hash => rocis_hash,
            :agency => AGENCY,
            :agency_sub_agency => AGENCY_SUB_AGENCY,
            :agency_locale => :en,
            :agency_display_name => AGENCY_DISPLAY_NAME,
            :uses_rocis_display_name => false })
  end

  def import
    super do |new_or_updated_forms|
      FORM_URLS.each do |url|
        doc = Nokogiri::HTML(open(url).read)
        doc.xpath(%q{//*[@id='main']/table[1]/tr}).each do |row|
          imported_form = import_form(row)
          new_or_updated_forms << imported_form if imported_form
        end
      end
    end
  end

  private

  def import_form(row)
    columns = row.xpath('./td')
    return if columns.empty?

    form_revision_date = Sanitize.clean(columns[2].inner_text.to_s).squish
    return if form_revision_date =~ /\ACANCELLED\Z/i

    form_number = Sanitize.clean(columns[0].inner_text.to_s)
    form_number.gsub!(/\u00A0/, ' ')
    form_number.squish!
    return if form_number.blank?

    if form_number =~ /^[[:alpha:]]+[[:digit:]]+/
      digit_position = form_number =~ /[[:digit:]]/
      form_number.insert(digit_position, '-')
    end

    title_link = columns[1].css('a').first
    form_title = Sanitize.clean(title_link.inner_text.to_s).squish
    landing_page_path = title_link.attr(:href).to_s.strip
    landing_page_url = "#{BASE_URL}#{landing_page_path}"

    form = @form_agency.forms.where(:number => form_number).first_or_initialize
    form.details.clear

    form.title = form_title
    form.landing_page_url = landing_page_url
    form_revision_date_string = Sanitize.clean(columns[2].inner_text.to_s).squish
    form.revision_date = case form_revision_date_string
                         when /^[[:alpha:]]+\s+[[:digit:]]+$/
                           Date.parse(form_revision_date_string). strftime('%-m/%y') rescue nil
                         end
    form.revision_date ||= form_revision_date_string

    fetch_links(form)
    if form.url.present?
      form.verified = true if form.new_record?
    else
      form.url = form.landing_page_url
      form.file_type = 'PDF'
      form.verified = false
    end

    populate_rocis_fields(form)
    form.save!
    form
  end

  def fetch_links(form)
    doc = Nokogiri::HTML(open(form.landing_page_url).read)

    urls = doc.css('a[href^="/whs/directives/infomgt/forms/eforms/"]')
    form.links = []

    urls.each_with_index do |url, index|
      absolute_url = url.attr(:href) =~ /^\// ? "#{BASE_URL}#{url.attr(:href)}" : url.attr(:href)
      title, format = case url.inner_text.to_s.squish
                        when /(pdf|word|excel|perf|ff 2\.0)/i
                          ["Form #{form.number}", lookup_format(absolute_url)]
                        else
                          [url.inner_text, lookup_format(absolute_url)]
                      end

      if index == 0
        form.url = absolute_url
        form.file_type = format
      end
      next if absolute_url == 'http://www.dtic.mil/whs/directives/infomgt/forms/issuance.htm'

      form.links << { :title => title, :file_type => format, :url => absolute_url }
    end

    if form.links.empty?
      form.url = nil
      form.verified = false
      return
    end

    tables = doc.css('table')
    tables.each do |table|
      next unless Sanitize.clean(table.inner_text.to_s).squish =~ /^ISSUANCES/
      issuances_urls = table.css('a')
      issuances_urls.each do |url|
        stripped_url = url.attr(:href).to_s.strip
        absolute_url = case url.attr(:href)
                         when /^\// then "#{BASE_URL}#{stripped_url}"
                         when /^http/ then stripped_url
                       end
        next unless absolute_url
        next if URLS_WITH_404.include?(absolute_url)

        title = url.inner_text.to_s.squish
        form.links << { :title => title, :file_type => lookup_format(absolute_url), :url => absolute_url }
      end
    end
  end
end