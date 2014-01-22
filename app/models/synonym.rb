class Synonym < ActiveRecord::Base
  STATES = %w{Candidate Approved Rejected}
  before_validation :format_entry

  def self.create_entry_for(entry, locale)
    find_or_create_by_locale_and_entry(locale, entry)
  rescue ActiveRecord::RecordNotUnique
    Rails.logger.warn "Already created record for '#{entry}' and '#{locale}'"
  end

  def label
    "#{self.class.name} #{self.id}"
  end

  private

  def format_entry
    self.entry = self.entry.split(',').collect(&:squish).sort.join(', ') if self.entry.present?
  end
end
