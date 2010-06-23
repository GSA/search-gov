class FoodRecall < ActiveRecord::Base
  validates_presence_of :url, :summary, :description, :food_type
  belongs_to :recall
end
