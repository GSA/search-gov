class QueryImpression
  def self.log(vertical, affiliate_name, query, modules, synonyms = [])
    query_impression_hash = {:time => Time.now.to_formatted_s(:db),
                             :affiliate => affiliate_name,
                             :locale => I18n.locale.to_s,
                             :query => query,
                             :vertical => vertical,
                             :modules => modules.join('|')}
    query_impression_hash.merge!(:synonyms => synonyms.join('|')) unless synonyms.empty?
    Rails.logger.info("[Query Impression] #{query_impression_hash.to_json}")
  end
end
