# frozen_string_literal: true

class BulkZombieUrlUploader
  MAXIMUM_FILE_SIZE = 4.megabytes
  VALID_CONTENT_TYPES = %w[text/plain].freeze

  attr_reader :results

  class Error < StandardError
  end

  class Results
    attr_accessor :searchgov_domains, :ok_count, :error_count, :name

    def initialize(name)
      @name = name
      @ok_count = 0
      @error_count = 0
      @searchgov_domains = Set.new
      @errors = Hash.new { |hash, key| hash[key] = [] }
    end

    def delete_ok
      self.ok_count += 1
    end

    def add_error(error_message, url)
      self.error_count += 1
      @errors[error_message] << url
    end

    def total_count
      ok_count + error_count
    end

    def urls_with(error_message)
      @errors[error_message]
    end
  end

  class UrlFileValidator
    def initialize(uploaded_file)
      @uploaded_file = uploaded_file
    end

    def validate!
      ensure_present
      ensure_valid_content_type
      ensure_not_too_big
    end

    def ensure_valid_content_type
      return if BulkZombieUrlUploader::VALID_CONTENT_TYPES.include?(@uploaded_file.content_type)

      error_message = "Files of type #{@uploaded_file.content_type} are not supported."
      raise(BulkZombieUrlUploader::Error, error_message)
    end

    def ensure_present
      return if @uploaded_file.present?

      error_message = 'Please choose a file to upload.'
      raise(BulkZombieUrlUploader::Error, error_message)
    end

    def ensure_not_too_big
      return if @uploaded_file.size <= BulkZombieUrlUploader::MAXIMUM_FILE_SIZE

      error_message = "#{@uploaded_file.original_filename} is too big; please split it."
      raise(BulkZombieUrlUploader::Error, error_message)
    end
  end

  def initialize(name, urls)
    @urls = urls
    @name = name
  end

  def upload
    @results = Results.new(@name)
    upload_urls
  end

  private

  def upload_urls
    @urls.each do |raw_url|
      process_url(raw_url)
    end
  end

  def process_url(raw_url)
    searchgov_url = SearchgovUrl.find_or_initialize_by(url: raw_url.strip)
    searchgov_url.destroy if searchgov_url.persisted?
    @results.delete_ok
  rescue StandardError => e
    @results.add_error(e.message, raw_url)
    Rails.logger.error "Failed to process url: #{raw_url}", e
  end
end
