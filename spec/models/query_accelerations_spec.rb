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

  describe '#biggest_movers_over_window' do
    context "when the table is populated" do
      before do
        [1, 7, 30].each do |window_size|
          4.times do |idx|
            daysago = idx + 1
            QueryAcceleration.create!(:day => daysago.days.ago.to_date, :query => "high score window_size=#{window_size} days ago= #{daysago}", :window_size => window_size, :score => window_size * daysago)
            QueryAcceleration.create!(:day => daysago.days.ago.to_date, :query => "low score window_size=#{window_size} days ago= #{daysago}", :window_size => window_size, :score => -window_size * daysago)
          end
        end
      end

      it "should find and sort biggest movers based on the day and window size parameter" do
        QueryAcceleration.biggest_movers_over_window(7).first.score.should == 7.0
        QueryAcceleration.biggest_movers_over_window(7).last.score.should == -7.0
      end

    end

    context "when the table has no data for the time period specified" do
      before do
        QueryAcceleration.delete_all
      end

      it "should return nil" do
        QueryAcceleration.biggest_movers_over_window(1).should be_nil
      end
    end
  end

end
