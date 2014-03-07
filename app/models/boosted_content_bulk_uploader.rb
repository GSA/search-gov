class BoostedContentBulkUploader
  require 'rexml/document'

  def initialize(site)
    @site = site
    @results = { created: 0, updated: 0, success: false }
    @records_hash = []
  end

  def upload(bulk_upload_file)
    filename = bulk_upload_file.original_filename.downcase
    raise ArgumentError unless filename =~ /\.(csv|txt)$/
    parse_csv(bulk_upload_file)
    import_boosted_contents
  rescue ArgumentError
    @results[:error_message] = "Your filename should have .csv or .txt extension."
  rescue
    @results[:error_message] = "Your document could not be processed. Please check the format and try again."
    Rails.logger.warn "Problem processing boosted Content document: #{$!}"
  ensure
    return @results
  end

  private

  def parse_csv(csv_file)
    CSV.parse(csv_file.read, :skip_blanks => true) do |row|
      publish_start_on = extract_date(row[3])
      publish_end_on = extract_date(row[4], nil)
      keywords = extract_keywords(row[5])

      @records_hash << { title: row[0],
                         url: row[1],
                         description: row[2],
                         publish_start_on: publish_start_on,
                         publish_end_on: publish_end_on,
                         keywords: keywords }
    end
  end

  def extract_date(date_string, default_value = Date.current)
    Date.parse(date_string) rescue default_value
  end

  def extract_keywords(keywords_string)
    return [] if keywords_string.blank?
    keywords_string.split(',').reject { |k| k.blank? }.map { |k| k.squish }
  end

  def import_boosted_contents
    @records_hash.each { |info| import_boosted_content(info) }
    @results[:success] = true
  end

  def import_boosted_content(attributes)
    boosted_content_attributes = attributes.except(:keywords).merge(status: 'active')
    boosted_content = @site.boosted_contents.find_or_initialize_by_url(boosted_content_attributes)

    if boosted_content.new_record?
      attributes[:keywords].each do |keyword|
        boosted_content.boosted_content_keywords.build(value: keyword)
      end
      boosted_content.save!
      @results[:created] += 1
    else
      boosted_content.assign_attributes(boosted_content_attributes)
      keywords = attributes[:keywords].map do |keyword|
        boosted_content.boosted_content_keywords.find_or_initialize_by_value(keyword)
      end
      BoostedContent.transaction do
        boosted_content.boosted_content_keywords = keywords
        boosted_content.save!
      end
      @results[:updated] += 1
    end
    boosted_content
  end
end
