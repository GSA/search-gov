class SynonymMiner
  @queue = :low

  def initialize(affiliate, words_per_affiliate = 1000, months_back = 12)
    @affiliate = affiliate
    @words_per_affiliate = words_per_affiliate
    @months_back = months_back
    @domains = @affiliate.site_domains.pluck(:domain)
  end

  def mine
    candidates.each { |candidate_group| Synonym.create_entry_for(candidate_group.join(', '), @affiliate.locale) }
  end

  def candidates
    raw_synonym_sets = scrape_synonyms(popular_single_word_terms)
    grouped_synonyms = group_overlapping_sets(raw_synonym_sets)
    probably_acronyms, all_single_words = grouped_synonyms.partition { |synonym_array| synonym_array.any? { |synonym| synonym.split.many? } }
    unstemmed_singles = filter_stemmed(all_single_words)
    (probably_acronyms + unstemmed_singles).sort
  end

  def group_overlapping_sets(raw_synonym_sets)
    grouped_synonyms = []
    while raw_synonym_sets.present?
      candidate = raw_synonym_sets.shift
      partition = raw_synonym_sets.partition { |set| (set & candidate).empty? }
      if partition.last.empty?
        grouped_synonyms << candidate
      else
        raw_synonym_sets = partition.first << (partition.last.flatten + candidate).uniq.sort
      end
    end
    grouped_synonyms.sort
  end

  def popular_single_word_terms
    conditions = ['day >= ? AND affiliate = ? and query not like "% %"', @months_back.months.ago.to_date, @affiliate.name]
    DailyQueryStat.sum(:times, group: :query, conditions: conditions, order: "sum_times desc", limit: @words_per_affiliate).collect(&:first)
  end

  def filter_stemmed(singles)
    singles.select { |synset| tokens_from_analyzer(synset).many? }
  end

  def tokens_from_analyzer(synset)
    options = { text: synset.join(' '), analyzer: "#{@affiliate.locale}_analyzer", index: ElasticIndexedDocument.writer_alias }
    ES::client.indices.analyze(options)['tokens'].collect { |t| t['token'] }.uniq
  end

  def scrape_synonyms(queries)
    queries.collect { |query| extract_equivalents(site_search_results(query)) }.uniq.select { |values| values.many? }
  end

  def site_search_results(query)
    search = SiteSearch.new(query: query, affiliate: @affiliate, per_page: 20)
    search.run
    search.results
  end

  def extract_equivalents(results)
    results.map { |result| extract_highlights(result["title"]) + extract_highlights(result["content"]) }.flatten.uniq.sort
  end

  def extract_highlights(field)
    field.gsub(/(,|['’]s)/i, '').scan(/\uE000([^\uE000]*)\uE001/).flatten.map(&:downcase).reject { |f| f =~ /\A[0-9]+\z/ } - @domains
  end

  def self.perform(affiliate_id, words_per_affiliate, months_back)
    affiliate = Affiliate.find affiliate_id
    synonym_miner = new(affiliate, words_per_affiliate, months_back)
    synonym_miner.mine
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn("Could not find affiliate #{affiliate_id} in SynonymMiner.perform()")
  end

end
