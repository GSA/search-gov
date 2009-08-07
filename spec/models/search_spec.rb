require "#{File.dirname(__FILE__)}/../spec_helper"

describe Search do

  before do
    @valid_options = {:queryterm => 'social security', :page => 3}
  end

  describe "when new" do
    it "should have a queryterm" do
      search = Search.new(@valid_options)
      search.queryterm.should == 'social security'
    end

    it "should not require a query" do
      lambda { Search.new }.should_not raise_error(ArgumentError)
    end
  end

  describe "when searching with valid queries" do
    before do
      @search = Search.new(@valid_options)
      @search.run
    end

    it "should find results based on query" do
      @search.results.size.should > 0
    end

    it "should have a total at least as large as the first set of results" do
      @search.total.should >= @search.results.size
    end

  end

  describe "when searching with invalid queries" do
    before do
      @search = Search.new(@valid_options.merge(:queryterm => 'kjdfgkljdhfgkldjshfglkjdsfhg'))
    end

    it "should not raise an exception when searching for invalid data" do
      @search.run.should be_true
    end

    it "should have 0 results for invalid search" do
      @search.run
      @search.results.size.should == 0
    end
  end

  describe "when paginating" do

    default_per_page = 8
    default_page = 0

    it "should default to page 0 if no valid page number was specified" do
      options_without_page = @valid_options.reject{|k,v| k == :page}
      Search.new(options_without_page).page.should == default_page
      Search.new(@valid_options.merge(:page => '')).page.should == default_page
      Search.new(@valid_options.merge(:page => 'string')).page.should == default_page
    end

    it "should set the page number" do
      search = Search.new(@valid_options.merge(:page => 2))
      search.page.should == 2
    end

    it "should default to 8 results per page" do
      search = Search.new(@valid_options)
      search.run
      search.results.size.should == default_per_page
    end

    it "should set startrecord/endrecord" do
      page = 7
      search = Search.new(@valid_options.merge(:page => page))
      search.run
      search.startrecord.should == default_per_page * page + 1
      search.endrecord.should == search.startrecord + search.results.size - 1
    end
  end
end
