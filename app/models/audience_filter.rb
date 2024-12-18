class AudienceFilter < Filter
  validates :label, presence: true, if: :enabled?
end
