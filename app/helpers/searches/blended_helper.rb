module Searches::BlendedHelper
  BLENDED_PARTIAL_HASH = {
    IndexedDocument: 'searches/blended/indexed_document',
    NewsItem: 'searches/news_item'
  }.freeze

  def blended_result_partial(result)
    BLENDED_PARTIAL_HASH[result.class.name.to_sym]
  end
end
