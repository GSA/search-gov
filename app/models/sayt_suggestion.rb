class SaytSuggestion < ActiveRecord::Base
  before_validation :squish_whitespace_and_downcase_and_spellcheck

  validates_presence_of :phrase
  validates_uniqueness_of :phrase
  validates_length_of :phrase, :within=> (3..80)
  validates_format_of :phrase, :with=> /^[a-zA-Z0-9][a-zA-Z0-9\s.'-]+[a-zA-Z0-9]$/i

  def self.like(query, num_suggestions)
    find(:all, :conditions => ['phrase LIKE ? ', query + '%'], :order => 'phrase ASC', :limit => num_suggestions, :select=> 'phrase')
  end

  def self.populate_for(day)
    filtered_daily_query_stats = SaytFilter.filter(
      DailyQueryStat.find_all_by_day_and_affiliate_and_locale(day, DailyQueryStat::DEFAULT_AFFILIATE_NAME, I18n.default_locale.to_s), "query")
    filtered_daily_query_stats.each do |dqs|
      create(:phrase => dqs.query)
    end unless filtered_daily_query_stats.empty?
  end

  def self.process_sayt_suggestion_txt_upload(txtfile)
    valid_content_types = ['application/octet-stream', 'text/plain' , 'txt']
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

  private

  def squish_whitespace_and_downcase_and_spellcheck
    self.phrase = Misspelling.correct(self.phrase.squish.downcase) unless self.phrase.nil?
  end
end
