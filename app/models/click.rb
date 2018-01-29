class Click
  def self.log(url, query, queried_at, click_ip, affiliate_name, position, results_source, vertical, locale, user_agent, model_id)
    click_hash = { :clicked_at => Time.now.to_formatted_s(:db),
                   :url => url,
                   :queried_at => queried_at,
                   :affiliate_name => affiliate_name,
                   :click_ip => click_ip,
                   :position => position,
                   :results_source => results_source,
                   :locale => locale,
                   :query => query,
                   :vertical => vertical,
                   :user_agent => user_agent,
                   :model_id => model_id
    }
    Rails.logger.info("[Click] #{click_hash.to_json}")
  end
end
