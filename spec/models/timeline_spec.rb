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
        dates = (9..15).to_a.reverse.collect {|x| x.days.ago.to_date}
        timeline = Timeline.new("foo")
        timeline.dates.should == dates
        timeline.series.collect {|d| d.y}.should == [1,0,0,1,1,0,1] 
      end
    end
  end
end
