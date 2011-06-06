class Click < ActiveRecord::Base
  validates_presence_of :queried_at, :url, :query, :results_source

  class << self
    def monthly_totals_by_module(year, month)
      start_datetime = Date.new(year, month, 1).to_time
      end_datetime = start_datetime + 1.month
      Click.count(:group => 'results_source',
                  :conditions=> {:clicked_at => start_datetime..end_datetime},
                  :order => "count_all desc",
                  :having => "count_all >= 10")
    end

    def monthly_totals_for_affiliate(year, month, affiliate)
      start_datetime = Date.new(year, month, 1).to_time
      end_datetime = start_datetime + 1.month
      Click.count(:conditions => {:clicked_at => start_datetime..end_datetime, :affiliate => affiliate})
    end

    def log(url, query, queried_at, click_ip, affiliate_name, position, results_source, vertical, locale, user_agent)
      click_hash = {:clicked_at=> Time.now.to_formatted_s(:db),
                    :url => url,
                    :queried_at => queried_at,
                    :affiliate_name => affiliate_name,
                    :click_ip => click_ip,
                    :position => position,
                    :results_source => results_source,
                    :locale => locale,
                    :query => query,
                    :vertical => vertical,
                    :user_agent=> user_agent}
      Rails.logger.info("[Click] #{click_hash.to_json}")
    end
  end
end
