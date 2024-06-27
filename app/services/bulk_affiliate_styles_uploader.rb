# frozen_string_literal: true

class BulkAffiliateStylesUploader
  MAXIMUM_FILE_SIZE = 4.megabytes
  VALID_CONTENT_TYPES = %w[text/plain].freeze
  URL_ALREADY_TAKEN_MESSAGE = 'Validation failed: Url has already been taken'

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

    def add_ok(url)
      self.ok_count += 1
      searchgov_domains << url.searchgov_domain
    end

    def add_error(error_message, url)
      self.error_count += 1
      @errors[error_message] << url
    end

    def total_count
      ok_count + error_count
    end

    def error_messages
      # Make sure the 'URL already taken' errors show up last, so as
      # not to obscure more actionable errors
      already_taken = ->(error) { error == URL_ALREADY_TAKEN_MESSAGE }
      errors = @errors.keys
      errors.reject(&already_taken) + errors.select(&already_taken)

      # @errors.keys
    end

    def urls_with(error_message)
      @errors[error_message]
    end
  end

  class AffiliateStylesFileValidator
    def initialize(uploaded_file)
      @uploaded_file = uploaded_file
    end

    def validate!
      ensure_present
      ensure_valid_content_type
      ensure_not_too_big
    end

    def ensure_valid_content_type
      return if BulkAffiliateStylesUploader::VALID_CONTENT_TYPES.include?(@uploaded_file.content_type)

      error_message = "Files of type #{@uploaded_file.content_type} are not supported."
      raise(BulkAffiliateStylesUploader::Error, error_message)
    end

    def ensure_present
      return if @uploaded_file.present?

      error_message = 'Please choose a file to upload.'
      raise(BulkAffiliateStylesUploader::Error, error_message)
    end

    def ensure_not_too_big
      return if @uploaded_file.size <= BulkAffiliateStylesUploader::MAXIMUM_FILE_SIZE

      error_message = "#{@uploaded_file.original_filename} is too big; please split it."
      raise(BulkAffiliateStylesUploader::Error, error_message)
    end
  end

  def initialize(name, urls, reindex: false)
    @urls = urls
    @name = name
    @reindex = reindex
  end

  def upload_and_index
    @results = Results.new(@name)
    upload_urls
    index_domains
  end

  private

  def upload_urls
    @urls.each do |raw_url|
      process_url(raw_url)
    end
  end

  def index_domains
    @results.searchgov_domains.each do |domain|
      Rails.logger.info "Starting indexing for #{domain.domain}"
      domain.index_urls
    end
  end

  def process_url(raw_url)
    searchgov_url = SearchgovUrl.find_or_initialize_by(url: raw_url.strip)
    searchgov_url.enqueued_for_reindex = true if searchgov_url.persisted? && @reindex
    searchgov_url.save!
    @results.add_ok(searchgov_url)
  rescue StandardError => e
    @results.add_error(e.message, raw_url)
  end
end
