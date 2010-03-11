class SaytSuggestion < ActiveRecord::Base
  validates_presence_of :phrase
  validates_uniqueness_of :phrase
  validates_length_of :phrase, :within=> (3..80)
  validates_format_of :phrase, :with=> /^[\w\s.'-]+$/i

  def self.populate_for(day)
    filtered_daily_query_stats = SaytFilter.filter(DailyQueryStat.find_all_by_day(day), "query")
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
          sayt_suggestion = find_or_initialize_by_phrase(:phrase => entry)
          if sayt_suggestion.new_record? and sayt_suggestion.valid?
            sayt_suggestion.save!
            created += 1
          else
            ignored += 1
          end
        end
      end
      return {:created => created, :ignored => ignored}
    end
  end
end
