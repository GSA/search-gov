module Api::V2::AsJsonAppendWebSpellingCorrection
  protected

  def as_json_append_web(hash)
    super do |web_hash|
      web_hash[:spelling_correction] = @spelling_suggestion
    end
  end
end
