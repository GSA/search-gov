class CalaisRelatedSearch < ActiveRecord::Base
  @queue = :calais_related_search
  @@redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT)

  DAILY_API_QUOTA = 49000
  BING_RESULTS_TO_CONSIDER_FOR_TEXT = 100
  CRS_REDIS_KEY_PREFIX = "calais_related_search_daily_count:"

  validates_presence_of :term, :related_terms, :locale
  validates_uniqueness_of :term, :scope => [:locale, :affiliate_id]
  validates_inclusion_of :locale, :in => SUPPORTED_LOCALES
  belongs_to :affiliate

  class << self

    def refresh_stalest_entries
      find_all_by_locale('en', :order => 'updated_at', :limit => daily_api_quota).each do |crs|
        affiliate_name = crs.affiliate.nil? ? Affiliate::USAGOV_AFFILIATE_NAME : crs.affiliate.name
        Resque.enqueue(CalaisRelatedSearch, affiliate_name, crs.term)
        break if @@redis.incr(CRS_REDIS_KEY_PREFIX + Date.today.to_s) >= daily_api_quota
      end
    end

    def populate_with_new_popular_terms
      stats_with_yesterdays_active_affiliates = DailyQueryStat.find(:all,
                                                                    :select=>"distinct(affiliate) affiliate",
                                                                    :conditions=>["day = ? and locale='en'", Date.yesterday])
      stats_with_yesterdays_active_affiliates.each do |dqs|
        populate_affiliate_with_new_popular_terms(dqs.affiliate)
        break if @@redis.get(CRS_REDIS_KEY_PREFIX + Date.today.to_s).to_i >= daily_api_quota
      end
    end

    def populate_affiliate_with_new_popular_terms(affiliate_name)
      if (affiliate_name == Affiliate::USAGOV_AFFILIATE_NAME)
        sub_select = "select distinct(term) from calais_related_searches where calais_related_searches.locale='en' and calais_related_searches.affiliate_id is null"
      else
        sub_select = "select distinct(term) from calais_related_searches, affiliates where calais_related_searches.locale='en' and affiliates.id=calais_related_searches.affiliate_id and affiliates.name = '#{affiliate_name}'"
      end

      yesterdays_popular_en_locale_terms_not_yet_in_related_searches_for_affiliate =
        DailyQueryStat.find(:all,
                            :select=>"daily_query_stats.query, sum(times) sum_times",
                            :conditions=>["daily_query_stats.locale='en' and daily_query_stats.affiliate = ? and daily_query_stats.day = ? and daily_query_stats.query not in (#{sub_select})",
                                          affiliate_name, Date.yesterday],
                            :group=>"daily_query_stats.query",
                            :order=>"sum_times desc")
      yesterdays_popular_en_locale_terms_not_yet_in_related_searches_for_affiliate.each do |dqs|
        Resque.enqueue(CalaisRelatedSearch, affiliate_name, dqs.query)
        break if @@redis.incr(CRS_REDIS_KEY_PREFIX + Date.today.to_s) >= daily_api_quota
      end
    end

    def perform(affiliate_name, term)
      affiliate = Affiliate.find_by_name(affiliate_name)
      affiliate_id = affiliate.nil? ? nil : affiliate.id

      search = Search.new(:query=>term, :affiliate=> affiliate, :results_per_page => BING_RESULTS_TO_CONSIDER_FOR_TEXT, :enable_highlighting=>false)
      search.run
      summary = search.results.collect { |r| [r['title'], r['content']].join('. ') }.join(' ')
      unless summary.blank?
        begin
          calais = Calais.process_document(:content => summary, :content_type => :raw, :license_id => CALAIS_LICENSE_ID, :metadata_enables=>['SocialTags'])
          downcased_term = term.downcase
          social_tags = calais.socialtags.collect { |st| st.name }
          social_tags.delete_if do |tag|
            downcased_tag = tag.downcase
            downcased_tag.include?('_') or downcased_term.include?(downcased_tag.singularize) or
              downcased_term.include?(downcased_tag.pluralize) or downcased_tag == downcased_term or
              downcased_tag == downcased_term.singularize or downcased_tag == downcased_term.pluralize
          end
          unless social_tags.empty?
            related_terms = social_tags.join(' | ')
            calais_related_search = find_or_initialize_by_term_and_locale_and_affiliate_id(term, 'en', affiliate_id)
            calais_related_search.related_terms = related_terms
            calais_related_search.save!
          end
        rescue NoMethodError, Nokogiri::XML::XPath::SyntaxError, Calais::Error, Curl::Err::TimeoutError, Curl::Err::GotNothingError, ArgumentError => error
          RAILS_DEFAULT_LOGGER.warn "Problem getting Calais Socialtags for #{affiliate_name}:#{term}: #{error}"
        end
      end
    end

    def daily_api_quota
      DAILY_API_QUOTA
    end

    def search_for(term, locale = I18n.default_locale.to_s, affiliate_id = nil)
      search do
        keywords term, :highlight=>true
        with :locale, locale
        with :affiliate_id, affiliate_id
        paginate :page => 1, :per_page => 2
      end rescue nil
    end

  end

  searchable do
    text :term, :boost => 5.0
    text :related_terms
    string :locale
    integer :affiliate_id
  end

  def to_label
    term
  end

end
