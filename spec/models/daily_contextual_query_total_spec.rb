require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DailyContextualQueryTotal do
  before do
    DailyContextualQueryTotal.delete_all
    @valid_attributes = {
      :day => Date.today,
      :total => 100
    }
    DailyContextualQueryTotal.create(@valid_attributes)
  end

  should_validate_numericality_of :total
  should_validate_uniqueness_of :day
  
  it "should create a new instance given valid attributes" do
    DailyContextualQueryTotal.create!(@valid_attributes.merge(:day => Date.yesterday))
  end

  context "when queries are present" do
    before do
      Query.create(:ipaddr => '127.0.0.1', :query => 'obama', :timestamp => Date.yesterday, :affiliate => 'usasearch.gov', :locale => 'en', :is_bot => false, :is_contextual => true)
      Query.create(:ipaddr => '127.0.0.1', :query => 'obama', :timestamp => Date.yesterday, :affiliate => 'usasearch.gov', :locale => 'en', :is_bot => false, :is_contextual => false)
      Query.create(:ipaddr => '127.0.0.1', :query => 'obama', :timestamp => Date.yesterday, :affiliate => 'usasearch.gov', :locale => 'en', :is_bot => true, :is_contextual => true)
    end
    
    it "should create a new instance and calculate the total if the total is null on save, and ignore any bots or non-contextual links" do
      daily_total = DailyContextualQueryTotal.create!(:day => Date.yesterday)
      daily_total.should_not be_nil
      daily_total.total.should == 1
    end
  end
  
  describe "#total_for" do
    before do     
      DailyContextualQueryTotal.create(:day => Date.yesterday, :total => 100)
    end
    
    it "should find the total for the specified date, ignoring any contextual links or bots" do
      daily_total = DailyContextualQueryTotal.total_for(Date.yesterday)
      daily_total.should == 100
    end
    
    it "should return 0 if there's no record for that date" do
      daily_total = DailyContextualQueryTotal.total_for(Date.today - 2.days)
      daily_total.should == 0
    end
  end
end
