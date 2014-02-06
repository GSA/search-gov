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

  def overlaps_with?(other_synonym)
    (self.entry.split(ENTRY_DELIMITER) & other_synonym.entry.split(ENTRY_DELIMITER)).present?
  end

  def self.format_entry(entry)
    arr = entry.is_a?(Array) ? entry : entry.split(',')
    arr.collect(&:squish).collect(&:downcase).sort.uniq.join(ENTRY_DELIMITER)
  end

  def self.group_overlapping_synonyms(locale, status)
    synonyms = where(locale: locale, status: status).order("length(entry) DESC")
    while synonyms.present?
      candidate = synonyms.shift
      overlapping, distinct = synonyms.partition { |synonym_instance| synonym_instance.overlaps_with?(candidate) }
      overlapping.each do |synonym_instance|
        candidate.update_attribute(:entry,format_entry([candidate.entry, synonym_instance.entry].join(ENTRY_DELIMITER)))
        synonym_instance.delete
      end
      synonyms = distinct
    end
  end

end
