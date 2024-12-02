# frozen_string_literal: true

class BulkZombieUrlUploader
  MAXIMUM_FILE_SIZE = 4.megabytes
  VALID_CONTENT_TYPES = %w[text/csv].freeze

  attr_reader :results

  class Error < StandardError; end

  def initialize(filename, filepath)
    @file_name = filename
    @file_path = filepath
  end

  def upload
    @results = BulkZombieUrls::Results.new(@file_name)
    begin
      upload_urls
    rescue => e
      error_message = 'Your document could not be processed. Please check the format and try again.'
      Rails.logger.error "Problem processing bulk zombie URL document: #{error_message} | #{e.message}"
    end
    @results
  end

  private

  def upload_urls
    parse_csv.each do |row|
      process_row(row)
    end
  rescue CSV::MalformedCSVError => e
    handle_csv_error(e)
  end

  def parse_csv
    CSV.parse(File.read(@file_path), headers: true)
  end

  def process_row(row)
    url = row['URL']&.strip
    document_id = row['DOC_ID']

    process_url_with_rescue(url, document_id, row)
  end

  def process_url_with_rescue(url, document_id, row)
    process_url(url, document_id)
    @results.delete_ok
    @results.updated += 1
  rescue StandardError => e
    handle_processing_error(e, url, document_id, row)
  end

  def handle_csv_error(error)
    @results.add_error('Invalid CSV format', 'Entire file')
    Rails.logger.error "Error parsing CSV: #{error.message}"
  end

  def handle_processing_error(error, url, document_id, row)
    @results.add_error(error.message, url || document_id)
    Rails.logger.error "Failure to process bulk upload zombie URL row: #{row.inspect}\n#{error.message}\n#{error.backtrace.join("\n")}"
  end  

  def process_url(url, document_id)
    searchgov_url = SearchgovUrl.find_by(url:)
    if searchgov_url
      searchgov_url.destroy
    else
      I14yDocument.delete(handle: 'searchgov', document_id:)
    end
  end
end
