class Misspelling < ActiveRecord::Base
  before_validation :squish_whitespace_and_downcase

  validates_presence_of :wrong, :rite
  validates_uniqueness_of :wrong
  validates_length_of :wrong, :within=> (3..80)
  validates_format_of :wrong, :with=> /^[\w\.'-]+$/iu

  def self.correct(phrase)
    return if phrase.nil?
    corrected = phrase.split.map do |word|
      correction = find_by_wrong(word)
      correction.nil? ? word : correction.rite
    end
    corrected.join(' ')
  end

  private

  def squish_whitespace_and_downcase
    self.wrong = self.wrong.squish.downcase unless self.wrong.nil?
    self.rite = self.rite.squish.downcase unless self.rite.nil?
  end
end
