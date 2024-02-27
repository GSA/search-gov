class SearchgovDomainDestroyerJob < ApplicationJob
  queue_as :searchgov

  def perform(searchgov_domain)
    ActiveRecord::Base.transaction do
      if destroy_associated_records(searchgov_domain.searchgov_urls, 'URL') && destroy_record(searchgov_domain, 'SearchgovDomain')
        Rails.logger.info("Successfully destroyed SearchgovDomain #{searchgov_domain.id} and its URLs.")
      else
        Rails.logger.error("Failed to completely destroy SearchgovDomain #{searchgov_domain.id} and its URLs.")
      end
    end
  end

  private

  def destroy_associated_records(records, record_type)
    records.find_each(batch_size: 100) { |record| return false unless destroy_record(record, record_type) }

    true
  end

  def destroy_record(record, record_type)
    unless record.destroy
      log_failure(record_type, record.id)
      return false
    end

    true
  end

  def log_failure(record_type, record_id)
    Rails.logger.error("Failed to destroy #{record_type} #{record_id}")
  end
end
