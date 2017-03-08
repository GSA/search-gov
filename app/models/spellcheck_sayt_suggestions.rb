class SpellcheckSaytSuggestions
  extend Resque::Plugins::Priority
  extend ResqueJobStats
  @queue = :primary

  def self.perform(wrong, rite)
    SaytSuggestion.where(['phrase LIKE ?', "%#{wrong}%"]).each do |s|
      corrected = s.phrase.gsub(/\b#{wrong}\b/, rite)
      if corrected != s.phrase
        SaytSuggestion.create(:phrase => corrected, :affiliate => s.affiliate)
        s.destroy
      end
    end
  end
end
