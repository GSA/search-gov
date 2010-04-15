class Click < ActiveRecord::Base
  validates_presence_of :queried_at, :url, :query, :results_source
end
