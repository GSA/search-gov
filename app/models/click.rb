class Click
  def self.log(url, query, click_ip, affiliate_name, position, results_source, vertical, user_agent, access_key=nil)
    click_hash = { :clicked_at => Time.now.to_formatted_s(:db),
                   :url => url,
                   :affiliate_name => affiliate_name,
                   :click_ip => click_ip,
                   :position => position,
                   :results_source => results_source,
                   :query => query,
                   :vertical => vertical,
                   :user_agent => user_agent,
                   :access_key => access_key
    }
    Rails.logger.info("[Click] #{click_hash.to_json}")
  end
end
