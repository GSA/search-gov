class CalaisRelatedSearch < ActiveRecord::Base
  validates_presence_of :term, :related_terms
  validates_uniqueness_of :term

  WEEK_AGO = 7
  BATCH_SIZE = 20000
  BING_RESULTS_TO_CONSIDER_FOR_TEXT = 100

  class << self

    def populate_with_new_popular_terms
      DailyQueryStat.most_popular_terms(Date.yesterday, WEEK_AGO, BATCH_SIZE).each do |dqs|
        term = dqs.query.downcase
        related_terms_for(term) unless exists?(:term => term)
      end
    end

    def related_terms_for(term)
      search = Search.new(:query=>term, :results_per_page => BING_RESULTS_TO_CONSIDER_FOR_TEXT, :enable_highlighting=>false)
      search.run
      summary = search.results.collect { |r| [r['title'], r['content']].join('. ') }.join(' ')
      unless summary.blank?
        begin
          calais = Calais.process_document(:content => summary, :content_type => :raw, :license_id => CALAIS_LICENSE_ID, :metadata_enables=>['SocialTags'])
          social_tags = calais.socialtags.collect { |st| st.name.downcase }
          [term, term.singularize, term.pluralize].each { |t| social_tags.delete(t) }
          social_tags.delete_if { |tag| tag.include?('_') or term.include?(tag.singularize) or term.include?(tag.pluralize) }
          unless social_tags.empty?
            related_terms = social_tags.join(' | ')
            calais_related_search = find_or_initialize_by_term(term)
            calais_related_search.related_terms = related_terms
            calais_related_search.save!
            logger.info("#{term} => #{related_terms}\n")
          end
        rescue Calais::Error => error
          RAILS_DEFAULT_LOGGER.warn "Error getting Calais results for #{term}: #{error}"
        end
      end
    end

    def search_for(term)
      search do
        keywords term, :highlight=>true
        paginate :page => 1, :per_page => 2
      end rescue nil
    end

  end

  searchable do
    text :term, :boost => 5.0
    text :related_terms
  end

end
