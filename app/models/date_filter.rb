class DateFilter < Filter
  validates :label, presence: true, if: :enabled?
end
