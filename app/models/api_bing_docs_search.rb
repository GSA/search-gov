class ApiBingDocsSearch < ApiBingSearch
  include ApiDocsSearch

  def as_json_result_hash(result)
    {
      title: result.title,
      url: result.unescaped_url,
      snippet: result.content
    }
  end
end