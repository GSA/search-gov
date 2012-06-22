class SpellcheckSaytSuggestions
  extend Resque::Plugins::Priority
  @queue = :primary

  def self.perform(wrong, rite)
    SaytSuggestion.find_each do |s|
      corrected = s.phrase.gsub(/\b#{wrong}\b/, rite)
      if corrected != s.phrase
        s.destroy if s.affiliate.nil?
        SaytSuggestion.create(:phrase => corrected)
      end
    end
  end
end