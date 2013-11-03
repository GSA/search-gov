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
    if %w(BBG BOOS).include? results_source
      affiliate_id = Affiliate.where(name: affiliate_name).pluck(:id).first rescue nil
      if affiliate_id
        keen_hash = { :affiliate_id => affiliate_id, :module => results_source, :url => url, :query => query, :model_id => model_id }
        ActiveSupport::Notifications.instrument("best_bets_publish.usasearch", :query => keen_hash) do
          Keen.publish_async(:clicks, keen_hash)
        end
      end
    end
  end
end
