class SystemAlert < ApplicationRecord
  validates_presence_of :message, :start_at
  validate :start_at_and_end_at
  scope :current, -> {
    where('(:now > start_at AND end_at IS NULL) OR (:now BETWEEN start_at AND end_at)',
          :now => DateTime.current).
    order('start_at ASC')
  }

  def start_at_and_end_at
    if start_at and end_at and start_at > end_at
      errors.add(:base, "End at can't be before start at")
    end
  end

  def to_label
    "System Alert: \"#{message}\", starting at #{start_at}"
  end
end
