class BulkAffiliateDeleteUploader < BulkUploaderBase
  def initialize(filename, filepath)
    super(filename, filepath, nil)
  end


  private

  def process_row(row)
    affiliate_id_text = extract_identifier_from_row(row)

    if affiliate_id_text.present?
      unless affiliate_id_text.match?(/^\d+$/)
        @results.add_failure(affiliate_id_text, 'Invalid format: Affiliate ID must be numeric.')
        Rails.logger.warn "Skipping row with non-numeric Affiliate ID '#{affiliate_id_text}' in #{self.class.name} for file: #{@file_name}"
        return
      end

      @results.add_valid_id(affiliate_id_text)
    else
      # Handle rows where the ID might be missing or blank
      raw_identifier = row.is_a?(Array) ? row[0].to_s.strip : 'N/A'
      @results.add_failure(raw_identifier.presence || 'N/A', 'Row contained no Affiliate ID.')
      Rails.logger.warn "Skipping row with missing Affiliate ID in #{self.class.name} for file: #{@file_name}"
    end
  end

  def finalize_results
    if !@results.errors? && @results.valid_affiliate_ids.empty? && @results.processed_count > 0
      @results.add_general_error('File parsed successfully, but no valid Affiliate IDs were found.')
    end

    @results.summary_message
  end
end
