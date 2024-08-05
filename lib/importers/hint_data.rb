module HintData
  HINT_DATA_URL = 'https://raw.githubusercontent.com/GSA/search.digitalgov.gov/gh-pages/hints.json'

  def self.reload
    hint_json = DocumentFetcher.fetch HINT_DATA_URL
    if hint_json && hint_json[:body]
      import_hints JSON.parse(hint_json[:body])
      {}
    else
      hint_json
    end
  rescue => e
    Rails.logger.error 'HintData.reload failed', e
    { error: e.message }
  end

  private

  def self.import_hints(new_hints)
    return unless new_hints.present?

    current_hints = new_hints.map do |name, value|
      hint = Hint.where(name: name).first_or_initialize
      hint.value = value
      hint.save!
      hint
    end
    Hint.where('id NOT IN (?)', current_hints.map(&:id)).delete_all
  end
end
