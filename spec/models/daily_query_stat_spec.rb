require 'spec_helper'

describe DailyQueryStat do
  fixtures :daily_query_stats, :affiliates
  before(:each) do
    @valid_attributes = {
      :day => "20090830",
      :query => "government",
      :times => 314,
      :affiliate => Affiliate::USAGOV_AFFILIATE_NAME
    }
  end

  describe 'validations on create' do
    it { should validate_presence_of :day }
    it { should validate_presence_of :query }
    it { should validate_presence_of :times }
    it { should validate_presence_of :affiliate }
    it { should validate_uniqueness_of(:query).scoped_to([:day, :affiliate]) }

    it "should create a new instance given valid attributes" do
      DailyQueryStat.create!(@valid_attributes)
    end

    it "should create a new instance with the default locale if none is specified" do
      @valid_attributes.delete(:locale)
      DailyQueryStat.create(@valid_attributes).locale.should == I18n.default_locale.to_s
    end

    context "when queries have extra internal whitespace and/or external whitespace" do
      before do
        @unsquished_query = '  this query  should be   squished.  '
        @squished_query = 'this query should be squished.'
      end

      it "should remove extra interal whitespace and strip whitespace off the ends on create" do
        DailyQueryStat.create(@valid_attributes.merge(:query => @unsquished_query)).query.should == @squished_query
      end

      it "should remove extra internal whitespace and strip whitespace off the ends on update" do
        daily_query_stat = DailyQueryStat.create(@valid_attributes.merge(:query => 'something'))
        daily_query_stat.id.should_not be_nil
        daily_query_stat.update_attributes(:query => @unsquished_query)
        daily_query_stat.query.should == @squished_query
      end
    end
  end

end
