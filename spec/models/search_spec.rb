require "#{File.dirname(__FILE__)}/../spec_helper"

describe Search do

  before do
    @valid_options = {:query => 'government', :page => 3}
  end

  describe "when new" do
    it "should have a query" do
      search = Search.new(@valid_options)
      search.query.should == 'government'
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

  describe "when searching with nonsense queries" do
    before do
      @search = Search.new(@valid_options.merge(:query => 'kjdfgkljdhfgkldjshfglkjdsfhg'))
    end

    it "should return true when searching" do
      @search.run.should be_true
    end

    it "should have 0 results" do
      @search.run
      @search.results.size.should == 0
    end
  end

  describe "when searching with really long queries" do
    before do
      @search = Search.new(@valid_options.merge(:query => "X"*10000))
    end

    it "should return false when searching" do
      @search.run.should be_false
    end

    it "should have 0 results" do
      @search.run
      @search.results.size.should == 0
    end

    it "should set error message" do
      @search.run
      @search.error_message.should_not be_nil
    end
  end

  describe "using different search indexes" do

    it "should default to GWebSearch" do
      Search.new(@valid_options).engine.should be_instance_of Gweb
    end

    xit "should be settable to GSS" do
      Search.new(@valid_options.merge(:engine => Search::ENGINES[:gss])).engine.should be_instance_of Gss
    end
    #
    #it "should run the appropriate search engine" do
    #  [ Search::GWEB_SEARCH,  Search::GSS_SEARCH ].each do |engine|
    #    search = Search.new(@valid_options.merge(:engine => engine))
    #    engine.should_receive(:new).once.and_return(
    #    search.stub!(:engine).and_return(engine)
    #    engine.should_receive(:run).once
    #    search.run
    #  end
    #
    #end


  end

  describe "when paginating" do
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

    it "should use the underlying engine's results per page" do
      search = Search.new(@valid_options)
      search.run
      search.results.size.should == search.per_page
    end

    it "should set startrecord/endrecord" do
      page = 7
      search = Search.new(@valid_options.merge(:page => page))
      search.run
      search.startrecord.should == search.per_page * page + 1
      search.endrecord.should == search.startrecord + search.results.size - 1
    end
  end
end
