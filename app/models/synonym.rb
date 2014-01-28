class Synonym < ActiveRecord::Base
  STATES = %w{Candidate Approved Rejected}
  before_validation :format_entry
  belongs_to :affiliate

  def self.create_entry_for(entry, affiliate)
    find_or_create_by_locale_and_entry(affiliate.locale, entry) do |synonym|
      synonym.affiliate = affiliate
    end
  rescue ActiveRecord::RecordNotUnique
    Rails.logger.warn "Already created record for '#{entry}' and '#{affiliate.locale}'"
  end

  def label
    "#{self.class.name} #{self.id}"
  end

  private

  def format_entry
    self.entry = self.entry.split(',').collect(&:squish).collect(&:downcase).sort.join(', ') if self.entry.present?
  end
end
