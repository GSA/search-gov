require 'spec/spec_helper'
describe Timeline do
  let(:start_date) do
    Date.yesterday.advance(:months => Timeline::DEFAULT_RANGE_IN_MONTHS)
  end

  let(:before_start_date) do
    start_date.advance(:months => -1)
  end

  describe "#new" do
    it "should generate a new Timeline object given a query" do
      Timeline.new("foo").should be_instance_of(Timeline)
    end

    context "when there are no records for the query term at all" do
      it "should return an array with zeros for each day from 13 months ago to yesterday" do
        timeline = Timeline.new("not in the database")
        timeline.dates.size.should == (Date.yesterday - start_date).to_i
        timeline.series.each do |timeline_entry|
          timeline_entry.y.should == 0
        end
      end

      context "when start_date is specified" do
        it "should return an array with zeroes for each day from start_date to yesterday" do
          custom_start_date = Date.yesterday.advance(:years => -2)
          timeline = Timeline.new("not in the database", nil, nil, custom_start_date)
          timeline.dates.size.should == (Date.yesterday - custom_start_date).to_i
          timeline.series.each do |timeline_entry|
            timeline_entry.y.should == 0
          end
        end
      end
    end

    context "when there are no searches for a term on a given day" do
      before do
        DailyQueryStat.create!(:day => Date.yesterday, :query => "most recent query", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        [2, 9, 11, 12, 15].each { |x| DailyQueryStat.create!(:day => Date.current.to_date - x.days, :query => "foo", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME) }
      end

      it "should fill in missing dates from 13 months ago and zero them out" do
        timeline = Timeline.new("foo")
        num_days = 1 + (Date.yesterday - start_date).to_i
        timeline.series.size.should == num_days
        [1, 3, 10, 13, 14].each { |x| timeline.series[timeline.dates.index(Date.current.to_date - x.days)].y.should == 0 }
      end
    end

    context "when data does not extend back to 13 months ago" do
      before do
        DailyQueryStat.create!(:day => Date.yesterday, :query => "foo", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      end
      it "should prepend the data with zeros so that there are data points back to 13 months ago" do
        timeline = Timeline.new("foo")
        timeline.dates.first.should == start_date
      end
    end

    context "when data extends back to 13 months ago" do
      before do
        DailyQueryStat.create!(:day => Date.yesterday, :query => "foo", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => start_date, :query => "foo", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      end

      it "should not prepend the data with zeros" do
        timeline = Timeline.new("foo")
        timeline.dates.first.should == start_date
        timeline.series.first.y.should == 1
      end
    end

    context "when data extends back to more than 13 months ago" do
      before do
        DailyQueryStat.create!(:day => Date.yesterday, :query => "foo", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => start_date, :query => "foo", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => before_start_date, :query => "foo", :times => 2, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      end

      it "should not load data older than 13 months ago" do
        timeline = Timeline.new("foo")
        timeline.dates.first.should == start_date
        timeline.series.first.y.should == 1
      end
    end

    context "when data does not extend forward to the most recently populated date" do
      before do
        DailyQueryStat.delete_all
        DailyQueryStat.create!(:day => Time.now.yesterday.yesterday.to_date, :query => "foo", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
        DailyQueryStat.create!(:day => Time.now.yesterday.to_date, :query => "bar", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      end

      it "should append the data with zeros so that there are data points thru the most recently populated date" do
        timeline = Timeline.new("foo")
        timeline.dates.last.should == Time.now.yesterday.to_date
      end
    end

    context "when data does extend forward to the most recently populated date" do
      before do
        DailyQueryStat.delete_all
        DailyQueryStat.create!(:day => Date.yesterday, :query => "foo", :times => 1, :affiliate => Affiliate::USAGOV_AFFILIATE_NAME)
      end

      it "should not append the data with zeros" do
        timeline = Timeline.new("foo")
        size= timeline.dates.size
        timeline.dates[size-1].should > timeline.dates[size-2]
        timeline.series[timeline.dates.index(Date.yesterday)].y.should == 1
      end
    end

    context "when Daily Query Stats exist for affiliates and locales besides the default" do
      before do
        DailyQueryStat.delete_all
        %w{ en es }.each do |locale|
          %w{ usasearch.gov affiliate.gov }.each do |affiliate|
            DailyQueryStat.create!(:day => Date.yesterday, :query => 'foo', :times => 1, :affiliate => affiliate, :locale => locale)
          end
        end
      end

      it "should combine non-default affiliate and locale query stats" do
        timeline = Timeline.new("foo")
        timeline.dates.last.should == Date.yesterday
        timeline.series.last.y.should == 4
      end
    end

    context "#load_daily_query_stats" do
      #Timeline.load_daily_query_stats('query')
    end

    context "#load_daily_query_stats" do
      #Timeline.load_daily_query_stats('query_group', is_grouped = false)
    end

    context "#load_affiliate_daily_query_stats" do
      fixtures :affiliates
      before do
        DailyQueryStat.delete_all

        DailyQueryStat.create!(:day => Date.yesterday.advance(:months => -3), :query => "foo", :times => 1, :affiliate => affiliates(:power_affiliate).name)
        DailyQueryStat.create!(:day => Date.yesterday.advance(:months => -2), :query => "foo", :times => 1, :affiliate => affiliates(:power_affiliate).name)

        DailyQueryStat.create!(:day => Date.yesterday.advance(:months => -1), :query => "foo", :times => 1, :affiliate => affiliates(:basic_affiliate).name)
      end

      it "should collection affiliate query stats" do
        DailyQueryStat.should_receive(:collect_affiliate_query).with('query', affiliates(:power_affiliate).name, start_date).and_return([])
        DailyQueryStat.should_not_receive(:collect_query)
        DailyQueryStat.should_not_receive(:collect_query_group_named)
        Timeline.load_affiliate_daily_query_stats('query', affiliates(:power_affiliate).name)
      end

      it "should append data with zeroes up to the most recently populated date" do
        timeline = Timeline.load_affiliate_daily_query_stats('foo', affiliates(:power_affiliate).name)
        timeline.dates.last.should == Date.yesterday.advance(:months => -2)
      end
    end
  end
end
