# frozen_string_literal: true

class BulkAffiliateSearchEngineUpdateUploader < BulkUploaderBase
  VALID_SEARCH_ENGINES = BulkAffiliateSearchEngineUpdateJob::VALID_SEARCH_ENGINES

  def initialize(filename, filepath)
    super(filename, filepath, nil)
  end

  private

  def process_row(row)
    affiliate_id_text = extract_identifier_from_row(row)
    search_engine_text = row[1]&.strip

    if affiliate_id_text.blank?
      @results.add_failure('N/A', 'Affiliate ID is missing.')
      Rails.logger.warn "Skipping row with missing Affiliate ID in #{self.class.name} for file: #{@file_name}"
      return
    end

    unless affiliate_id_text.match?(/^\d+$/)
      @results.add_failure(affiliate_id_text, 'Invalid format: Affiliate ID must be numeric.')
      Rails.logger.warn "Invalid Affiliate ID '#{affiliate_id_text}' in #{self.class.name} for file: #{@file_name}"
      return
    end

    if search_engine_text.blank?
      @results.add_failure(affiliate_id_text, "Search engine is missing for Affiliate ID '#{affiliate_id_text}'.")
      Rails.logger.warn "Skipping row with missing Search Engine for Affiliate ID '#{affiliate_id_text}' in #{self.class.name}"
      return
    end

    unless VALID_SEARCH_ENGINES.include?(search_engine_text)
      @results.add_failure(affiliate_id_text, "Invalid search engine '#{search_engine_text}'. Must be one of: #{VALID_SEARCH_ENGINES.join(', ')}.")
      Rails.logger.warn "Invalid Search Engine '#{search_engine_text}' for Affiliate ID '#{affiliate_id_text}' in #{self.class.name}"
      return
    end

    @results.success_items << { id: affiliate_id_text, search_engine: search_engine_text }
  end

  def finalize_results
    if !@results.errors? && @results.success_items.empty? && @results.processed_count.positive?
      @results.add_general_error('File parsed successfully, but no valid Affiliate IDs and Search Engines were found.')
    elsif @results.processed_count.zero?
      @results.add_general_error("The uploaded file '#{@file_name}' is empty or contains no processable data.")
    end
  end
end