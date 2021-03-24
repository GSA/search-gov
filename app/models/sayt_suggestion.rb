# frozen_string_literal: true

class SaytSuggestion < ApplicationRecord
  include Dupable

  LETTERS_WITH_DIACRITIC = 'áéíóúÁÉÍÓÚüÜñÑ¿¡'

  before_validation :squish_whitespace_and_downcase
  before_save :set_whitelisted_status
  validates :affiliate, presence: true
  validates_presence_of :phrase
  validates_uniqueness_of :phrase, scope: :affiliate_id, case_sensitive: false
  validates_length_of :phrase, within: (3..80)
  validates_format_of :phrase, with: /\A[a-z0-9#{LETTERS_WITH_DIACRITIC}]+([\s_\.'\-]+[a-z0-9#{LETTERS_WITH_DIACRITIC}]+)*\z/iu
  belongs_to :affiliate

  MAX_POPULARITY = 2**30

  class << self
    def related_search(query, affiliate, options = {})
      return [] unless affiliate.is_related_searches_enabled?
      search_options = { affiliate_id: affiliate.id,
                         language: affiliate.indexing_locale,
                         size: 5,
                         q: query }.reverse_merge(options)
      elastic_results = ElasticSaytSuggestion.search_for(search_options)
      elastic_results.results.collect { |result| result.phrase }
    end

    def fetch_by_affiliate_id(affiliate_id, query, num_of_suggestions)
      clause = 'phrase LIKE ? AND affiliate_id=? AND ISNULL(deleted_at)'
      suggestions = where([clause, "#{query}%", affiliate_id]).
        order('popularity DESC, phrase ASC').
        limit(num_of_suggestions).
        select(:phrase)
      suggestions[0, num_of_suggestions]
    end

    def populate_for(day, limit)
      name_id_list = Affiliate.select([:id, :name]).collect { |aff| { name: aff.name, id: aff.id } }
      name_id_list.each { |element| populate_for_affiliate_on(element[:name], element[:id], day, limit) }
    end

    def populate_for_affiliate_on(affiliate_name, affiliate_id, day, limit)
      Resque.enqueue(SaytSuggestionDiscovery, affiliate_name, affiliate_id, day, limit)
    end

    def process_sayt_suggestion_txt_upload(txtfile, affiliate)
      valid_content_types = %w(application/octet-stream text/plain txt)
      if valid_content_types.include?(txtfile.content_type)
        created, ignored = 0, 0
        txtfile.tempfile.readlines.each do |phrase|
          entry = phrase.chomp.strip
          unless entry.blank?
            create(phrase: entry, affiliate: affiliate, is_protected: true, popularity: MAX_POPULARITY).id.nil? ? (ignored += 1) : (created += 1)
          end
        end
        { created: created, ignored: ignored }
      end
    end

    def expire(days_back)
      where(
        'updated_at < ? AND is_protected = ?',
        days_back.days.ago.beginning_of_day.to_s(:db),
        false
      ).in_batches.destroy_all
    end

  end

  def squish_whitespace_and_downcase
    self.phrase = phrase.squish.downcase unless phrase.nil?
  end

  def spellcheck
    self.phrase = Misspelling.correct(phrase) unless phrase.nil?
  end

  def squish_whitespace_and_downcase_and_spellcheck
    squish_whitespace_and_downcase
    spellcheck
  end

  def to_label
    phrase
  end

  def set_whitelisted_status
    self.is_whitelisted = true if SaytFilter.filters_match?(SaytFilter.accept, phrase)
  end
end
