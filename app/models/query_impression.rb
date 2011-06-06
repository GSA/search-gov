class QueryImpression
  def self.log(vertical, affiliate_name, query, modules)
    query_impression_hash = {:time=> Time.now.to_formatted_s(:db),
                             :affiliate => affiliate_name,
                             :locale => I18n.locale.to_s,
                             :query => query,
                             :vertical => vertical,
                             :modules=> modules.join('|')}
    Rails.logger.info("[Query Impression] #{query_impression_hash.to_json}")
  end
end
