class Misspelling < ActiveRecord::Base
  before_validation :squish_whitespace_and_downcase

  validates_presence_of :wrong, :rite
  validates_uniqueness_of :wrong
  validates_length_of :wrong, :within=> (3..80)
  validates_format_of :wrong, :with=> /^[\w\.'-]+$/iu

  after_save :spell_check_existing_sayt_suggestions

  def self.correct(phrase)
    return if phrase.nil?
    corrected = phrase.split.map do |word|
      correction = find_by_wrong(word)
      correction.nil? ? word : correction.rite
    end
    corrected.join(' ')
  end

  private
  def spell_check_existing_sayt_suggestions
    SaytSuggestion.all.each do |s|
      corrected = s.phrase.gsub(/\b#{wrong}\b/, rite)
      if corrected != s.phrase
        s.delete if s.affiliate.nil?
        SaytSuggestion.create(:phrase =>corrected)
      end
    end
  end

  def squish_whitespace_and_downcase
    self.wrong = self.wrong.squish.downcase unless self.wrong.nil?
    self.rite = self.rite.squish.downcase unless self.rite.nil?
  end
end
