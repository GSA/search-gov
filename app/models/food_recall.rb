class FoodRecall < ActiveRecord::Base
  validates_presence_of :url, :summary, :description
  belongs_to :recall
end
