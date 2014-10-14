class Synonym < ActiveRecord::Base
  STATES = %w{Candidate Approved Rejected}
  ENTRY_DELIMITER = ', '
  belongs_to :affiliate
  scope :approved, where(:status => 'Approved')
  scope :candidates, where(:status => 'Candidate')

  def self.create_entry_for(candidate_group, affiliate)
    entry = format_entry(candidate_group)
    find_or_create_by_locale_and_entry(affiliate.locale, entry) do |synonym|
      synonym.affiliate = affiliate
    end
  rescue ActiveRecord::RecordNotUnique
    Rails.logger.warn "Already created record for '#{entry}' and '#{affiliate.locale}'"
  end

  def label
    "#{self.class.name} #{self.id}"
  end

  def self.format_entry(entry)
    arr = entry.is_a?(Array) ? entry : entry.split(',')
    arr.collect(&:squish).collect(&:downcase).sort.uniq.join(ENTRY_DELIMITER)
  end

end
