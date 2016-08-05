class ApiAzureDocsSearch < ApiAzureSearch
  include ApiDocsSearch

  def as_json_result_hash(result)
    {
      title: result.title,
      url: result.url,
      snippet: result.description,
    }
  end
end