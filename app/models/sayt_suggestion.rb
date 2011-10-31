class SaytSuggestion < ActiveRecord::Base
  LETTERS_WITH_DIACRITIC = "áéíóúÁÉÍÓÚüÜñÑ¿¡"
  @queue = :medium
  before_validation :squish_whitespace_and_downcase
  before_validation :spellcheck, :unless => :affiliate
  belongs_to :affiliate

  validates_presence_of :phrase
  validates_uniqueness_of :phrase, :scope => :affiliate_id
  validates_length_of :phrase, :within=> (3..80)
  validates_format_of :phrase, :with=> /^[a-zA-Z0-9#{LETTERS_WITH_DIACRITIC}][\s\w\.'-]+[a-zA-Z0-9#{LETTERS_WITH_DIACRITIC}]$/iu

  MAX_POPULARITY = 2**30

  class << self

    def like(affiliate_id, query, num_suggestions)
      equals_is = affiliate_id.nil? ? 'is' : '='
      clause = "phrase LIKE ? AND affiliate_id #{equals_is} ? AND ISNULL(deleted_at)"
      where([clause, query + '%', affiliate_id]).order('popularity DESC, phrase ASC').limit(num_suggestions).select("phrase")
    end

    def prune_dead_ends
      all.each do |ss|
        unless Search.results_present_for?(ss.phrase, ss.affiliate)
          Rails.logger.info "Deleting #{ss.phrase} for affiliate #{ss.affiliate.name rescue Affiliate::USAGOV_AFFILIATE_NAME}"
          ss.delete
        end
      end
    end

    def populate_for(day)
      name_id_list = Affiliate.all.collect { |aff| {:name => aff.name, :id => aff.id} }
      name_id_list << {:name => Affiliate::USAGOV_AFFILIATE_NAME, :id => nil}
      name_id_list.each { |element| populate_for_affiliate_on(element[:name], element[:id], day) }
    end

    def populate_for_affiliate_on(affiliate_name, affiliate_id, day)
      Resque.enqueue(SaytSuggestion, affiliate_name, affiliate_id, day)
    end

    def perform(affiliate_name, affiliate_id, day)
      affiliate = Affiliate.find_by_id affiliate_id
      ordered_hash = DailyQueryStat.sum(:times, :group=> "query", :conditions=>["day = ? and affiliate = ?", day, affiliate_name])
      daily_query_stats = ordered_hash.map { |entry| DailyQueryStat.new(:query=> entry[0], :times=> entry[1]) }
      filtered_daily_query_stats = SaytFilter.filter(daily_query_stats, "query")
      filtered_daily_query_stats.each do |dqs|
        if Search.results_present_for?(dqs.query, affiliate, false) then
          temp_ss = new(:phrase => dqs.query)
          temp_ss.squish_whitespace_and_downcase_and_spellcheck
          sayt_suggestion = find_or_initialize_by_affiliate_id_and_phrase_and_deleted_at(affiliate_id, temp_ss.phrase, nil)
          if sayt_suggestion
            sayt_suggestion.popularity = dqs.times
            sayt_suggestion.save
          end
        end
      end unless filtered_daily_query_stats.empty?
    end

    def process_sayt_suggestion_txt_upload(txtfile, affiliate = nil)
      valid_content_types = ['application/octet-stream', 'text/plain', 'txt']
      if valid_content_types.include? txtfile.content_type
        created, ignored = 0, 0
        txtfile.tempfile.readlines.each do |phrase|
          entry = phrase.chomp.strip
          unless entry.blank?
            create(:phrase => entry, :affiliate => affiliate, :is_protected => true, :popularity => MAX_POPULARITY).id.nil? ? (ignored += 1) : (created += 1)
          end
        end
        return {:created => created, :ignored => ignored}
      end
    end

    def expire(days_back)
      delete_all(["updated_at < ? AND is_protected = ?", days_back.days.ago.beginning_of_day.to_s(:db), false])
    end
  end

  def squish_whitespace_and_downcase
    self.phrase = self.phrase.squish.downcase unless self.phrase.nil?
  end

  def spellcheck
    self.phrase = Misspelling.correct(self.phrase) unless self.phrase.nil?
  end

  def squish_whitespace_and_downcase_and_spellcheck
    squish_whitespace_and_downcase
    spellcheck
  end

  def to_label
    phrase
  end
end