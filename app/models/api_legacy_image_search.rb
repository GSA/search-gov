class ApiLegacyImageSearch < LegacyImageSearch
  protected

  def backfill_needed?
    false
  end
end
