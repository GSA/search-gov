class CalaisRelatedSearch < ActiveRecord::Base
  SUPPORTED_LOCALES = %w{en es}
  BATCH_SIZE = 10000
  BING_RESULTS_TO_CONSIDER_FOR_TEXT = 100

  validates_presence_of :term, :related_terms, :locale
  validates_uniqueness_of :term, :scope => :locale
  validates_inclusion_of :locale, :in => SUPPORTED_LOCALES

  class << self

    def populate_with_new_popular_terms
      popular_en_locale_terms_not_yet_in_related_searches =
        DailyQueryStat.find(:all,
                            :select=>"daily_query_stats.query, sum(times) sum_times",
                            :joins=>"left outer join calais_related_searches on calais_related_searches.term = daily_query_stats.query",
                            :conditions=>"calais_related_searches.term is null and daily_query_stats.locale='en'",
                            :group=>"daily_query_stats.query",
                            :order=>"sum_times desc",
                            :limit => BATCH_SIZE)
      popular_en_locale_terms_not_yet_in_related_searches.each { |dqs| related_terms_for(dqs.query.downcase) }
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
            calais_related_search = find_or_initialize_by_term_and_locale(term, 'en')
            calais_related_search.related_terms = related_terms
            calais_related_search.save!
            logger.info("#{term} => #{related_terms}\n")
          end
        rescue Calais::Error => error
          RAILS_DEFAULT_LOGGER.warn "Problem getting Calais Socialtags for #{term}: #{error}"
        rescue NoMethodError => error
          RAILS_DEFAULT_LOGGER.warn "Problem parsing Calais XML results for #{term}: #{error}"
        rescue Nokogiri::XML::XPath::SyntaxError => error
          RAILS_DEFAULT_LOGGER.warn "Error parsing Calais XML results for #{term}: #{error}"
        end
      end
    end

    def search_for(term, locale = I18n.default_locale.to_s)
      search do
        keywords term, :highlight=>true
        with :locale, locale
        paginate :page => 1, :per_page => 2
      end rescue nil
    end

  end

  searchable do
    text :term, :boost => 5.0
    text :related_terms
    string :locale
  end

  def to_label
    term
  end

end
