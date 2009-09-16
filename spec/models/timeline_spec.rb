require "#{File.dirname(__FILE__)}/../spec_helper"
describe Timeline do

  describe "#new" do
    it "should generate a new Timeline object given a query" do
      Timeline.new("foo").should be_instance_of(Timeline)
    end

    context "when there are no searches for a term on a given day" do
      before do
        [9,11,12,15].each {|x| DailyQueryStat.create!(:day => x.days.ago.to_date, :query => "foo", :times => 1 )}
      end

      it "should fill in missing dates and zero them out" do
        timeline = Timeline.new("foo")
        [10,13,14].each { |x| timeline.series[timeline.dates.index(x.days.ago.to_date)].y.should == 0 }
      end
    end

    context "when data does not extend back to Jan 1, 2009" do
      before do
        DailyQueryStat.create!(:day => Date.yesterday, :query => "foo", :times => 1 )
      end
      it "should prepend the data with zeros so that there are data points back to Jan 1, 2009" do
        timeline = Timeline.new("foo")
        timeline.dates.first.should == Date.new(2009,01,01)
      end
    end

    context "when data extends back to Jan 1, 2009" do
      before do
        DailyQueryStat.create!(:day => Date.yesterday, :query => "foo", :times => 1 )
        DailyQueryStat.create!(:day => Date.new(2009,1,1), :query => "foo", :times => 1 )
      end
      it "should not prepend the data with zeros" do
        timeline = Timeline.new("foo")
        timeline.dates.first.should == Date.new(2009,01,01)
        timeline.series.first.y.should == 1
      end
    end

    context "when data does not extend forward to the most recently populated date" do
      before do
        DailyQueryStat.create!(:day => 2.days.ago.to_date, :query => "foo", :times => 1 )
        DailyQueryStat.create!(:day => 1.day.ago.to_date, :query => "bar", :times => 1 )
      end
      it "should append the data with zeros so that there are data points thru the most recently populated date" do
        timeline = Timeline.new("foo")
        timeline.dates.last.should == Date.yesterday
      end
    end

    context "when data does extend forward to the most recently populated date" do
      before do
        DailyQueryStat.create!(:day => 1.day.ago.to_date, :query => "foo", :times => 1 )
      end
      it "should not append the data with zeros" do
        timeline = Timeline.new("foo")
        size= timeline.dates.size
        timeline.dates[size-1].should > timeline.dates[size-2]
        timeline.series[timeline.dates.index(Date.yesterday)].y.should == 1
      end
    end
  end
end
