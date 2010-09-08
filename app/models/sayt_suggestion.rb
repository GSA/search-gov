class SaytSuggestion < ActiveRecord::Base
  before_validation :squish_whitespace_and_downcase_and_spellcheck
  belongs_to :affiliate

  validates_presence_of :phrase
  validates_uniqueness_of :phrase, :scope => :affiliate_id
  validates_length_of :phrase, :within=> (3..80)
  validates_format_of :phrase, :with=> /^[a-zA-Z0-9][a-zA-Z0-9\s.'-]+[a-zA-Z0-9]$/i

  class << self

    def like(affiliate_id, query, num_suggestions)
      equals_is = affiliate_id.nil? ? 'is' : '='
      clause = "phrase LIKE ? AND affiliate_id #{equals_is} ?"
      find(:all, :conditions => [clause, query + '%', affiliate_id], :order => 'popularity DESC',
           :limit => num_suggestions, :select=> 'phrase')
    end

    def populate_for(day)
      name_id_list = Affiliate.all.collect { |aff| {:name => aff.name, :id => aff.id} }
      name_id_list << {:name => DailyQueryStat::DEFAULT_AFFILIATE_NAME, :id => nil}
      name_id_list.each { |element| populate_for_affiliate_on(element[:name], element[:id], day) }
    end

    def populate_for_affiliate_on(affiliate_name, affiliate_id, day)
      filtered_daily_query_stats = SaytFilter.filter(
        DailyQueryStat.find_all_by_day_and_affiliate_and_locale(day, affiliate_name, I18n.default_locale.to_s),
        "query")
      filtered_daily_query_stats.each do |dqs|
        temp_ss = new(:phrase => dqs.query)
        temp_ss.squish_whitespace_and_downcase_and_spellcheck
        sayt_suggestion = find_or_initialize_by_affiliate_id_and_phrase(affiliate_id, temp_ss.phrase)
        sayt_suggestion.popularity = dqs.times
        sayt_suggestion.save
      end unless filtered_daily_query_stats.empty?
    end

    def process_sayt_suggestion_txt_upload(txtfile)
      valid_content_types = ['application/octet-stream', 'text/plain', 'txt']
      if valid_content_types.include? txtfile.content_type
        created, ignored = 0, 0
        txtfile.readlines.each do |phrase|
          entry = phrase.chomp.strip
          unless entry.blank?
            create(:phrase => entry).id.nil? ? (ignored += 1) : (created += 1)
          end
        end
        return {:created => created, :ignored => ignored}
      end
    end

    def expire(days_back)
      delete_all(["updated_at < ?", days_back.days.ago.beginning_of_day.to_s(:db)])
    end
  end

  def squish_whitespace_and_downcase_and_spellcheck
    self.phrase = Misspelling.correct(self.phrase.squish.downcase) unless self.phrase.nil?
  end
end
