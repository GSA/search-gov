class SpellcheckSaytSuggestions
  @queue = :high

  def self.perform(wrong, rite)
    SaytSuggestion.all.each do |s|
      corrected = s.phrase.gsub(/\b#{wrong}\b/, rite)
      if corrected != s.phrase
        s.destroy if s.affiliate.nil?
        SaytSuggestion.create(:phrase => corrected)
      end
    end
  end
end