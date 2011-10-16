require 'spec/spec_helper'

describe DailyPopularQueryGroup do

  let(:valid_attributes) { {
    :query_group_name => "Some Query Group",
    :day => Date.yesterday,
    :times => 100,
    :time_frame => 1
  } }

  describe "creating a new instance" do
    subject { DailyPopularQueryGroup.create!(valid_attributes) }

    it { should validate_presence_of :query_group_name }
    it { should validate_presence_of :day }
    it { should validate_presence_of :times }
    it { should validate_presence_of :time_frame }
    it { should validate_uniqueness_of(:query_group_name).scoped_to([:day, :time_frame]) }
  end

  describe "#calculate(day, time_frame)" do
    before do
      ResqueSpec.reset!
    end

    it "should enqueue calculation of popular query groups for the default/null USASearch affiliate" do
      DailyPopularQueryGroup.calculate(Date.current, 7)
      DailyPopularQueryGroup.should have_queued(Date.current, 7)
      DailyPopularQueryGroup.should have_queue_size_of(1)
    end
  end

  describe "#perform(day, time_frame)" do
    context "when there is sufficient data for the dates specified" do
      it "should calculate the USASearch affiliate's daily popular query groups for the given day and time frame" do
        day = Date.yesterday
        time_frame = 7
        DailyQueryStat.should_receive(:most_popular_query_groups).with(day, time_frame, 1000, Affiliate::USAGOV_AFFILIATE_NAME).and_return [QueryCount.new("QG Name", 100 * time_frame)]
        DailyPopularQueryGroup.perform(day.to_s, time_frame)
        DailyPopularQueryGroup.find_by_day_and_query_group_name_and_time_frame_and_times(day, "QG Name", time_frame, time_frame * 100).should_not be_nil
      end
    end

    context "when there is insufficient data for the dates specified" do
      before do
        DailyPopularQueryGroup.delete_all
      end

      it "should not create a DailyPopularQueryGroup record" do
        day = Date.yesterday
        time_frame = 7
        DailyQueryStat.should_receive(:most_popular_query_groups).with(day, time_frame, 1000, Affiliate::USAGOV_AFFILIATE_NAME).and_return "Insufficient data"
        DailyPopularQueryGroup.perform(day.to_s, time_frame)
        DailyPopularQueryGroup.count.should be_zero
      end
    end

    it "should handle existing records in the DB for that day/time_frame" do
      2.times { DailyPopularQueryGroup.perform(valid_attributes[:day].to_s, valid_attributes[:time_frame]) }
    end

  end
end