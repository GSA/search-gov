require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QueryAcceleration do
  fixtures :query_accelerations
  before(:each) do
    @valid_attributes = {
      :day => "20090830",
      :query => "government",
      :window_size => 7,
      :score => 314.15
    }
  end

  describe 'validations on create' do
    should_validate_presence_of(:day, :query, :window_size, :score)
    should_validate_uniqueness_of :query, :scope => [:day, :window_size]

    it "should create a new instance given valid attributes" do
      QueryAcceleration.create!(@valid_attributes)
    end
  end

end
