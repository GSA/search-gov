class AffiliateNote < ActiveRecord::Base
  belongs_to :affiliate
  attr_accessible :note
  before_save :strip_note, if: :note?

  def to_label
    note.to_s.truncate(90, separator: ' ')
  end

  private

  def strip_note
    self.note = note.strip
  end
end
