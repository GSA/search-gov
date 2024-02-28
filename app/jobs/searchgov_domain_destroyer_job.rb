class SearchgovDomainDestroyerJob < ApplicationJob
  queue_as :searchgov

  def perform(searchgov_domain)
    ActiveRecord::Base.transaction do
      if destroy_associated_records(searchgov_domain.searchgov_urls) && destroy_record(searchgov_domain)
        Rails.logger.info("Successfully destroyed SearchgovDomain #{searchgov_domain.id} and its URLs.")
      else
        Rails.logger.error("Failed to completely destroy SearchgovDomain #{searchgov_domain.id} and its URLs.")
      end
    end
  end

  private

  def destroy_associated_records(records)
    records.find_each(batch_size: 100) do |record|
      return false unless destroy_record(record)
    end

    true
  end

  def destroy_record(record)
    return false unless record.destroy

    true
  end
end
