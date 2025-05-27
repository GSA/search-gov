class BulkUploaderBase
  attr_reader :results, :file_name, :file_path, :requesting_user

  class Results
    attr_accessor :processed_count, :failed_count, :success_items, :error_details, :general_errors, :valid_affiliate_ids, :valid_affiliate_data
    attr_writer :summary_message

    def initialize(file_name)
      @file_name = file_name
      @processed_count = 0
      @failed_count = 0
      @success_items = []
      @error_details = []
      @general_errors = []
      @summary_message = nil
      @valid_affiliate_ids = []
      @valid_affiliate_data = []
    end

    def add_valid_id(id)
      @valid_affiliate_ids << id
    end

    def add_success(identifier)
      @success_items << identifier
    end

    def add_failure(identifier, error_message)
      @failed_count += 1
      @error_details << { identifier: identifier || 'N/A', error: error_message }
    end

    def add_general_error(error_message)
      @general_errors << error_message
    end

    def errors?
      @failed_count.positive? || @general_errors.any?
    end

    def summary_message
      return @summary_message if @summary_message

      if @general_errors.any?
        "File parsing failed: #{@general_errors.join('; ')}"
      elsif @error_details.any? || @failed_count.positive?
        valid_count = @valid_affiliate_ids.count

        if valid_count.positive?
          "File parsing partially completed. #{valid_count} valid ID(s) found, #{@failed_count} row(s) had errors. Deletion job proceeding. Check email for final results."
        else
          "File parsing completed with errors. No valid IDs found, #{@failed_count} row(s) failed."
        end

      elsif @valid_affiliate_ids.empty? && @processed_count > 0
        "File parsed, but no valid Affiliate IDs were found."
      elsif @valid_affiliate_ids.empty? && @processed_count == 0
        "File contained no data rows."
      else
        "File parsed successfully. Found #{@valid_affiliate_ids.count} valid ID(s). Deletion job proceeding. Check email for final results."
      end
    end
  end

  def self.csv_has_headers?
    false
  end

  def initialize(filename, filepath, requesting_user)
    @file_name = filename
    @file_path = filepath
    @requesting_user = requesting_user
    @results = Results.new(@file_name)
  end

  def parse_file
    begin
      process_file_rows
    rescue CSV::MalformedCSVError => e
      @results.add_general_error("CSV file is malformed: #{e.message}")
    rescue StandardError => e
      log_unexpected_error(e)
      @results.add_general_error("An unexpected error occurred during processing.")
    ensure
      finalize_results
    end

    @results
  end

  private

  def process_file_rows
    options = { headers: self.class.csv_has_headers? }

    CSV.foreach(@file_path, **options) do |row|
      @results.processed_count += 1
      begin
        process_row(row)
      rescue StandardError => e
        identifier = extract_identifier_from_row(row)
        @results.add_failure(identifier, "Error processing row: #{e.message}")
        log_row_processing_error(row, e)
      end
    end

    check_for_empty_file
  end

  def process_row(row)
    raise NotImplementedError, "#{self.class.name} must implement the 'process_row' method."
  end

  def finalize_results
    # Default method does nothing.
  end

  def extract_identifier_from_row(row)
    identifier = row[0]
    identifier.to_s.strip.presence
  rescue StandardError
    'Unknown Row Identifier'
  end

  def check_for_empty_file
    if @results.processed_count == 0 && !@results.errors?
      @results.add_general_error('No data rows found in the CSV file.')
    end
  end

  def log_unexpected_error(error)
    Rails.logger.error <<~LOG.squish
      Bulk Upload Error (#{self.class.name} - File: #{@file_name}):
      #{error.message}
      Backtrace: #{error.backtrace.first(10).join("\n")}
    LOG
  end

  def log_row_processing_error(row, error)
    Rails.logger.error <<~LOG.squish
      Error processing bulk upload row for #{self.class.name} (File: #{@file_name}):
      Row: #{row.inspect} - Error: #{error.message}
    LOG
  end
end