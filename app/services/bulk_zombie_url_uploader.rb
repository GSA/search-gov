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
    CSV.parse(File.read(@file_path), headers: true).each do |row|
      url = row['URL']&.strip
      document_id = row['DOC_ID']

      begin
        process_url(url, document_id)
        @results.delete_ok
        @results.updated += 1
      rescue StandardError => e
        @results.add_error(e.message, url || document_id)
        Rails.logger.error "Failure to process bulk upload zombie URL row: #{row.inspect}\n#{e.message}\n#{e.backtrace.join("\n")}"
      end
    end
  rescue CSV::MalformedCSVError => e
    @results.add_error('Invalid CSV format', 'Entire file')
    Rails.logger.error "Error parsing CSV: #{e.message}"
  end

  def process_url(url, document_id)
    searchgov_url = SearchgovUrl.find_by(url: url)
    if searchgov_url
      searchgov_url.destroy
    else
      I14yDocument.delete(handle: 'searchgov', document_id: document_id)
    end
  end
end
