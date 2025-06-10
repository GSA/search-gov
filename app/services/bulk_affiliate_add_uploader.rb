class BulkAffiliateAddUploader < BulkUploaderBase
  def initialize(filename, filepath, email_address)
    super(filename, filepath, email_address)
  end

  private

  def process_row(row)
    affiliate_name = extract_identifier_from_row(row)

    if affiliate_name.present?
      if Affiliate.exists?(name: affiliate_name)
        @results.add_valid_id(affiliate_name)
      else
        @results.add_failure(affiliate_name, 'Affiliate name not found.')
        logger.warn "Skipping row with invalid Affiliate name '#{affiliate_name}' in #{self.class.name} for file: #{@file_name}"
      end
    else
      @results.add_failure('N/A', 'Row contained no Affiliate name.')
      logger.warn "Skipping row with empty Affiliate name in #{self.class.name} for file: #{@file_name}"
    end
  end

  def finalize_results
    if @results.valid_affiliate_ids.empty? && @results.processed_count > 0
      if !@results.errors? || @results.failed_count == @results.processed_count
        @results.add_general_error('File parsed successfully, but no valid Affiliate names were found.')
      end
    end

    @results.summary_message
  end
end