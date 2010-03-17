class RecallDetail < ActiveRecord::Base
  belongs_to :recall
  validates_presence_of :detail_type, :detail_value 
end
