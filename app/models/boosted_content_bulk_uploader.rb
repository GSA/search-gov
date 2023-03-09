class BoostedContentBulkUploader
  require 'rexml/document'

  def initialize(site, file)
    @site = site
    @results = { created: 0, updated: 0, failed: 0, success: false }
    @file = file
  end

  def upload
    filename = @file.original_filename.downcase
    raise ArgumentError unless filename =~ /\.(csv|txt)$/
    import_boosted_contents
    @results[:success] = true
  rescue ArgumentError
    @results[:error_message] = "Your filename should have .csv or .txt extension."
    Rails.logger.error "Problem processing boosted Content document: ArgumentError: #{$!}"
  rescue
    @results[:error_message] = "Your document could not be processed. Please check the format and try again."
    Rails.logger.error "Problem processing boosted Content document: #{$!}"
  ensure
    return @results
  end

  private

  def import_boosted_contents
    contents = @file.read.encode('UTF-8', **{ invalid: :replace,
                                           undef:   :replace,
                                           replace: '' })

    CSV.parse(contents, skip_blanks: true,
                        headers: includes_header?(contents),
                        skip_lines: /^(?:,\s*)+$/) do |row|

      begin
        attributes = extract_attributes(row)
        create_or_update_boosted_content(attributes)
      rescue StandardError => error
        Rails.logger.error "Failure to process bulk upload BBT row:\n#{row}\n#{error.message}\n#{error.backtrace.join("\n")}"
        @results[:failed] += 1
      end
    end
  end

  def extract_attributes(row)
    keywords = extract_keywords(row[5])

    { title: row[0],
      url: row[1],
      description: row[2],
      publish_start_on: extract_date(row[3]),
      publish_end_on: extract_date(row[4], nil),
      keywords: keywords,
      match_keyword_values_only: extract_bool(row[6]) && keywords.present?,
      status: extract_status(row[7]) }
  end

  def extract_date(date_string, default_value = Date.current)
    Date.parse(date_string) rescue default_value
  end

  def extract_keywords(keywords_string)
    return [] if keywords_string.blank?
    keywords_string.split(',').compact_blank.map(&:squish)
  end

  def extract_bool(bool)
    bool.present? && bool =~ /^(1|true|yes|y|on)$/i
  end

  def extract_status(status)
    (%w{0 inactive}.include? status.to_s.downcase) ? 'inactive' : 'active'
  end

  def create_or_update_boosted_content(attributes)
    boosted_content_attributes = attributes.except(:keywords)
    boosted_content = @site.boosted_contents.find_or_initialize_by(url: boosted_content_attributes[:url]) do |bc|
      bc.assign_attributes(boosted_content_attributes)
    end

    if boosted_content.new_record?
      attributes[:keywords].each do |keyword|
        boosted_content.boosted_content_keywords.build(value: keyword)
      end
      boosted_content.save!
      @results[:created] += 1
    else
      boosted_content.assign_attributes(boosted_content_attributes)
      keywords = attributes[:keywords].map do |keyword|
        boosted_content.boosted_content_keywords.find_or_initialize_by(value: keyword)
      end
      BoostedContent.transaction do
        boosted_content.boosted_content_keywords = keywords
        boosted_content.save!
      end
      @results[:updated] += 1
    end
    boosted_content
  end

  def includes_header?(file)
    first_row = CSV.parse(file, skip_blanks: true, headers: false)[0]
    first_row[0..2].map(&:downcase) == ["title", "url", "description"]
  end
end
