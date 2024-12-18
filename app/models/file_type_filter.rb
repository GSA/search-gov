class FileTypeFilter < Filter
  validates :label, presence: true, if: :enabled?
end
