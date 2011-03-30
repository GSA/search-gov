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
  
  it { should validate_presence_of :name }
  it { should validate_presence_of :column_number }
  it { should validate_presence_of :sort_order }
  it { should validate_uniqueness_of(:sort_order).scoped_to(:column_number) }
  it { should validate_numericality_of :column_number }
  it { should ensure_inclusion_of(:column_number).in_range(1..3).with_low_message(/must be greater than or equal/).with_high_message(/must be less than or equal/) }
  it { should validate_numericality_of :sort_order }
  it { should_not allow_value(0).for(:sort_order) }  
end