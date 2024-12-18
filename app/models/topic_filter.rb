class TopicFilter < Filter
  validates :label, presence: true, if: :enabled?
end
