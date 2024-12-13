# frozen_string_literal: true

class BulkZombieUrlUploader
  attr_reader :results

  class Error < StandardError; end

  def initialize(filename, filepath)
    @file_name = filename
    @file_path = filepath
    @results = nil
  end

  def upload
    initialize_results
    process_upload
  rescue StandardError => e
    log_upload_error(e)
  ensure
    @results ||= BulkZombieUrls::Results.new(@file_name) 
  end

  private

  def initialize_results
    @results = BulkZombieUrls::Results.new(@file_name)
    raise Error, 'Results object not initialized' unless @results
  end

  def process_upload
    parse_csv.each { |row| process_row(row) }
  rescue CSV::MalformedCSVError => e
    handle_csv_error(e)
  end

  def parse_csv
    csv = CSV.parse(File.read(@file_path), headers: true)
    raise CSV::MalformedCSVError, "Missing required headers" unless %w[URL DOC_ID].all? { |col| csv.headers.include?(col) }
    csv
  rescue CSV::MalformedCSVError, ArgumentError => e
    raise CSV::MalformedCSVError.new('CSV', "Malformed or invalid CSV: #{e.message}")
  end

  def process_row(row)
    raise Error, 'Results object not initialized' unless @results

    url = row['URL']&.strip
    document_id = row['DOC_ID']&.strip

    return log_missing_document_id(row, url) if document_id.blank?

    handle_url_processing(url, document_id, row)
  end

  def handle_url_processing(url, document_id, row)
    process_url_with_rescue(url, document_id)
    update_results
  rescue StandardError => e
    handle_processing_error(e, url, document_id, row)
  end

  def update_results
    @results.delete_ok
    @results.increment_updated
  end

  def log_missing_document_id(row, url)
    @results.add_error('Document ID is missing', url || 'Unknown')
    Rails.logger.error("Skipping row: #{row.inspect}. Document ID is mandatory.")
  end

  def handle_csv_error(error)
    @results.add_error('Invalid CSV format', 'Entire file')
    Rails.logger.error("Error parsing CSV: #{error.message}")
  end

  def log_upload_error(error)
    error_message = "Failed to process bulk zombie URL document (file: #{@file_name})."
    backtrace = error.backtrace ? error.backtrace.join("\n") : 'No backtrace available'
    Rails.logger.error("#{error_message} Error: #{error.message}\n#{backtrace}")
  end

  def handle_processing_error(error, url, document_id, row)
    key = url.presence || document_id
    @results&.add_error(error.message, key)
    backtrace = error.backtrace ? error.backtrace.join("\n") : 'No backtrace available'
    Rails.logger.error("Failure to process bulk upload zombie URL row: #{row.inspect}\n#{error.message}\n#{backtrace}")
  end

  def process_url_with_rescue(url, document_id)
    process_url(url, document_id)
  end

  def process_url(url, document_id)
    if url.present?
      process_url_with_searchgov(url, document_id)
    else
      delete_document(document_id)
    end
  end

  def process_url_with_searchgov(url, document_id)
    searchgov_url = SearchgovUrl.find_by(url:)
    searchgov_url ? searchgov_url.destroy : delete_document(document_id)
  end

  def delete_document(document_id)
    I14yDocument.delete(handle: 'searchgov', document_id:)
  end
end
