class Click < ActiveRecord::Base
  validates_presence_of :queried_at, :url, :query, :results_source

  def self.monthly_totals_by_module(year, month)
    start_datetime = Date.new(year,month,1).to_time
    end_datetime = start_datetime + 1.month
    Click.count(:group => 'results_source',
                :conditions=> {:clicked_at => start_datetime..end_datetime},
                :order => "count_all desc",
                :having => "count_all >= 10")
  end
end
