class TopForm < ActiveRecord::Base
  validates_presence_of :name, :column_number, :sort_order
  validates_uniqueness_of :sort_order, :scope => :column_number
  validates_numericality_of :column_number, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 3
  validates_numericality_of :sort_order, :greater_than_or_equal_to => 1  
end
