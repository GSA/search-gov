require "#{File.dirname(__FILE__)}/../spec_helper"

describe TopForm do
  before do
    @valid_options = {
      :name => 'A Top Form',
      :url => 'http://usa.gov/AForm.pdf',
      :column_number => 1,
      :sort_order => 1
    }
    TopForm.create!(@valid_options)
  end
  
  should_validate_presence_of :name, :column_number, :sort_order
  should_validate_uniqueness_of :sort_order, :scope => :column_number
  should_validate_numericality_of :column_number, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 3
  should_validate_numericality_of :sort_order, :greater_than_or_equal_to => 1  
end