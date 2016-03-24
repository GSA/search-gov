class ApiI14ySearch < I14ySearch
  include Api::V2::NonCommercialSearch

  protected

  def result_url(result)
    result.link
  end
end