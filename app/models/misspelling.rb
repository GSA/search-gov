# coding: utf-8
class Misspelling < ApplicationRecord
  LETTERS_WITH_DIACRITIC = "áéíóúÁÉÍÓÚüÜñÑ¿¡"
  before_validation :squish_whitespace_and_downcase

  validates_presence_of :wrong, :rite
  validates_uniqueness_of :wrong, :case_sensitive => false
  validates_length_of :wrong, :within=> (3..80)
  validates_format_of :wrong, :with=> /\A[\w#{LETTERS_WITH_DIACRITIC}.'-]+\z/iu

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
