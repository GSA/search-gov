# frozen_string_literal: true

class BulkUrlUploader
  MAXIMUM_FILE_SIZE = 10.megabytes
  VALID_CONTENT_TYPES = %w[text/plain txt].freeze

  attr_reader :results

  class Error < StandardError
  end

  class Results
    attr_accessor :domains, :ok_count, :error_count, :name

    def initialize(name)
      @name= name
      @ok_count = 0
      @error_count = 0
      @domains = Set.new
      @errors = Hash.new {|hash, key| hash[key] = []}
    end

    def add_ok(url)
      @ok_count += 1
      @domains << url.searchgov_domain
    end

    def add_error(error_message, url)
      @error_count += 1
      @errors[error_message] << url
    end

    def total_count
      ok_count + error_count
    end

    def error_messages
      @errors.keys
    end

    def urls_with(error_message)
      @errors[error_message]
    end
  end

  def initialize(name, url_file)
    @url_file= url_file
    @results= Results.new(name)
  end

  def upload_and_index
    upload_urls
    index_domains
  end

  def upload_urls
    @url_file.each_line do |raw_url|
      add_url(raw_url)
    end
  end

  def index_domains
    @results.domains.each do |domain|
      Rails.logger.info "Starting indexing for #{domain.domain}"
      domain.index_urls
    end
  end

  def add_url(raw_url)
    raw_url.strip!
    begin
      url = SearchgovUrl.create!(url: raw_url)
      @results.add_ok(url)
    rescue ActiveRecord::RecordInvalid => e
      @results.add_error(e.message, raw_url)
    end
  end
end
