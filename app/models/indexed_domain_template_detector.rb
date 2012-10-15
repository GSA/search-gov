class IndexedDomainTemplateDetector
  extend Resque::Plugins::Priority
  @queue = :primary

  PAIR_SAMPLES = 10
  WORD_COUNT_THRESHOLD = 6
  PAGE_COUNT_THRESHOLD = 10
  SATURATION_THRESHOLD_PCT = 60.0
  SUBSTRING_LENGTH_SIMILARITY_THRESHOLD_PCT = 75.0

  def self.perform(indexed_domain_id)
    if (indexed_domain = IndexedDomain.find_by_id indexed_domain_id)
      indexed_domain_template_detector = IndexedDomainTemplateDetector.new(indexed_domain)
      if (detected_substring = indexed_domain_template_detector.detect_common_substring)
        common_substring = indexed_domain.common_substrings.find_or_initialize_by_substring(detected_substring.substring)
        common_substring.saturation = detected_substring.saturation
        common_substring.save!
      end
    end
  end

  def initialize(indexed_domain)
    @indexed_domain = indexed_domain
  end

  def detect_common_substring
    good_html_idocs_ids = get_good_html_idocs_ids
    return unless good_html_idocs_ids.size >= PAGE_COUNT_THRESHOLD
    candidate_substrings = get_candidate_substrings(good_html_idocs_ids)
    local_lcs = get_local_longest_common_substring(candidate_substrings)
    if local_lcs.split(' ').size >= WORD_COUNT_THRESHOLD
      saturation = compute_saturation(local_lcs)
      return CommonSubstring.new(:substring => local_lcs, :saturation => saturation) if saturation >= SATURATION_THRESHOLD_PCT
    end
    nil
  end

  def get_local_longest_common_substring(candidate_substrings)
    local_lcs = candidate_substrings.shift
    while candidate_substrings.any?
      smaller_lcs = local_lcs.longest_common_substring(candidate_substrings.shift)
      local_lcs = smaller_lcs if (100.0 * smaller_lcs.length / local_lcs.length) >= SUBSTRING_LENGTH_SIMILARITY_THRESHOLD_PCT
    end
    local_lcs.strip
  end

  def get_candidate_substrings(good_html_idocs_ids)
    candidate_substrings_hash = {}
    PAIR_SAMPLES.times do
      lcs = get_candidate_substring_between_random_document_pair(good_html_idocs_ids)
      saturation = compute_saturation(lcs)
      candidate_substrings_hash[lcs] = saturation
    end
    candidate_substrings_hash.sort_by { |ignore, sat| -sat }.collect(&:first)
  end

  def get_candidate_substring_between_random_document_pair(good_html_idocs_ids)
    idx = rand(good_html_idocs_ids.size-1)
    doc1, doc2 = IndexedDocument.find([good_html_idocs_ids[idx], good_html_idocs_ids[idx+1]])
    doc1.body_for_substring_detection.longest_common_substring(doc2.body_for_substring_detection)
  end

  def compute_saturation(lcs)
    target_population_size = @indexed_domain.indexed_documents.html.where(['body like ?', '%' + lcs + '%']).count
    100.0 * target_population_size / total_html_docs_for_domain
  end

  def total_html_docs_for_domain
    @total_html_docs_for_domain ||= @indexed_domain.indexed_documents.html.count
  end

  def get_good_html_idocs_ids
    @indexed_domain.indexed_documents.ok.html.select(:id).collect(&:id)
  end
end