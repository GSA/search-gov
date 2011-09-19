require 'spec/spec_helper'

describe DailyPopularQuery do
  fixtures :affiliates
  before do
    @valid_attributes = {
      :affiliate => affiliates(:basic_affiliate),
      :day => Date.yesterday,
      :locale => nil,
      :query => 'america',
      :times => 100,
      :is_grouped => false,
      :time_frame => 1
    }
  end

  describe "creating a new instance" do
    before do
      @daily_popular_query = DailyPopularQuery.create!(@valid_attributes)
    end

    it { should belong_to :affiliate }
    it { should validate_presence_of :day }
    it { should validate_presence_of :query }
    it { should validate_presence_of :times }
    it { should validate_presence_of :time_frame }
    it { should validate_uniqueness_of(:query).scoped_to([:day, :affiliate_id, :is_grouped, :time_frame]) }
  end

  describe "#most_recent_populated_date" do
    it "should return the most recent date entered into the table for nil affiliate and locale" do
      DailyPopularQuery.should_receive(:maximum).with(:day, :conditions => ['ISNULL(affiliate_id) AND locale=?', I18n.default_locale.to_s])
      DailyPopularQuery.most_recent_populated_date
    end

    it "should return the most recent date for an affiliate if an affiliate is passed in" do
      affiliate = affiliates(:basic_affiliate)
      DailyPopularQuery.should_receive(:maximum).with(:day, :conditions => ['affiliate_id=? AND locale=?', affiliate.id, I18n.default_locale.to_s])
      DailyPopularQuery.most_recent_populated_date(affiliate)
    end

    it "should return the most recent date for a locale if specified" do
      affiliate = affiliates(:basic_affiliate)
      DailyPopularQuery.should_receive(:maximum).with(:day, :conditions => ['affiliate_id=? AND locale=?', affiliate.id, 'es'])
      DailyPopularQuery.most_recent_populated_date(affiliate, 'es')
    end
  end

  describe "#calculate(day, time_frame, method, is_grouped)" do
    before do
      ResqueSpec.reset!
    end

    context "when is_grouped is false" do
      let(:is_grouped) { false }

      it "should enqueue calculation of popular queries for each affiliate, including the default/null USASearch affiliate" do
        DailyPopularQuery.calculate(Date.current, 7, :most_popular_terms, is_grouped)
        DailyPopularQuery.should have_queued(Date.current, 7, :most_popular_terms, is_grouped)
        Affiliate.all.each { |affiliate| DailyPopularQuery.should have_queued(Date.current, 7, :most_popular_terms, is_grouped, affiliate.id) }
      end
    end

    context "when is_grouped is true" do
      let(:is_grouped) { true }

      it "should enqueue calculation of popular queries for just the default/null USASearch affiliate" do
        DailyPopularQuery.calculate(Date.current, 7, :most_popular_terms, is_grouped)
        DailyPopularQuery.should have_queued(Date.current, 7, :most_popular_terms, is_grouped)
        DailyPopularQuery.should have_queue_size_of(1)
      end
    end
  end

  describe "#perform(day, time_frame, method, is_grouped, affiliate_id)" do
    it "should remove existing records from the DB for that day/time_frame/grouping/affiliate" do
      DailyPopularQuery.should_receive(:delete_all).once.with(["day = ? and time_frame = ? and is_grouped = ? and affiliate_id = ?", @valid_attributes[:day], @valid_attributes[:time_frame], @valid_attributes[:is_grouped], @valid_attributes[:affiliate].id])
      DailyPopularQuery.perform(@valid_attributes[:day].to_s, @valid_attributes[:time_frame], "most_popular_terms", @valid_attributes[:is_grouped], @valid_attributes[:affiliate].id)
    end

    context "when there is sufficient data for the dates specified" do
      let(:day) { Date.yesterday }
      let(:time_frame) { 7 }
      let(:is_grouped) { false }

      context "when it's a real affiliate" do
        let(:affiliate) { affiliates(:basic_affiliate) }

        it "should calculate the affiliate's daily popular queries for the given day, time frame, and grouping using the specified DailyQueryStat method" do
          DailyQueryStat.should_receive(:most_popular_terms).with(day, time_frame, 1000, affiliate.name).and_return [QueryCount.new("someterm", 100 * time_frame)]
          DailyPopularQuery.perform(day.to_s, time_frame, "most_popular_terms", is_grouped, affiliate.id)
          DailyPopularQuery.find_by_day_and_affiliate_id_and_locale_and_query_and_is_grouped_and_time_frame_and_times(
            day, affiliate.id, 'en', "someterm", is_grouped, time_frame, time_frame * 100).should_not be_nil
        end
      end

      context "when it's the default USASearch null affiliate" do

        it "should calculate the USASearch affiliate's daily popular queries for the given day, time frame, and grouping using the specified DailyQueryStat method" do
          DailyQueryStat.should_receive(:most_popular_terms).with(day, time_frame, 1000, Affiliate::USAGOV_AFFILIATE_NAME).and_return [QueryCount.new("someterm", 100 * time_frame)]
          DailyPopularQuery.perform(day.to_s, time_frame, "most_popular_terms", is_grouped, nil)
          DailyPopularQuery.find_by_day_and_affiliate_id_and_locale_and_query_and_is_grouped_and_time_frame_and_times(
            day, nil, 'en', "someterm", is_grouped, time_frame, time_frame * 100).should_not be_nil
        end
      end
    end

    context "when there is insufficient data for the dates specified" do
      before do
        DailyPopularQuery.delete_all
      end

      let(:day) { Date.yesterday }
      let(:time_frame) { 7 }
      let(:is_grouped) { false }

      it "should not create a DailyPopularQuery record" do
        DailyQueryStat.should_receive(:most_popular_terms).with(day, time_frame, 1000, Affiliate::USAGOV_AFFILIATE_NAME).and_return "Insufficient data"
        DailyPopularQuery.perform(day.to_s, time_frame, "most_popular_terms", is_grouped)
        DailyPopularQuery.count.should be_zero
      end
    end


  end
end