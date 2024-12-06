class CustomFilter < Filter
  validates :label, presence: true, if: :enabled?
end
