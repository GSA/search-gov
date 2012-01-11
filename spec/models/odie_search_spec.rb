require 'spec/spec_helper'

describe OdieSearch do
  fixtures :affiliates

  let(:affiliate) { affiliates(:basic_affiliate) }

  before do
    affiliate.indexed_documents.create!(:url => 'http://nps.gov/something.pdf', :title => 'The Fifth Element', :last_crawled_at => Time.now, :last_crawl_status => "OK")
    IndexedDocument.reindex
  end

  describe "#initialize(options)" do
    let(:search) { OdieSearch.new( { :query => '   element   OR', :affiliate => affiliate }) }

    it "should downcase a query ending in OR" do
      search.query.should == "element or"
    end

    it "should strip extra whitespace" do
      search.query.should == "element or"
    end

    context "when the query param isn't set" do
      it "should set 'query' to a blank string" do
        OdieSearch.new(:affiliate => affiliate).query.should be_blank
      end
    end
  end

  describe "#run" do
    it "should log info about the query and module impressions" do
      search = OdieSearch.new(:query => 'element', :affiliate => affiliate)
      QueryImpression.should_receive(:log).with(:odie, affiliate.name, 'element', ["ODIE"])
      search.run
    end

    context "when searching with really long queries" do
      before do
        @search = OdieSearch.new({:query => "X" * (Search::MAX_QUERYTERM_LENGTH + 1), :affiliate => affiliate})
      end

      it "should return false when searching" do
        @search.run.should be_false
      end

      it "should have 0 results" do
        @search.run
        @search.results.size.should == 0
        @search.total.should == 0
      end

      it "should set error message" do
        @search.run
        @search.error_message.should_not be_nil
      end
    end

    context "when searching with a blank query" do
      before do
        @search = OdieSearch.new({:query => "   ", :affiliate => affiliate})
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
  end
  
  describe "#cache_key" do
    before do
      @search = OdieSearch.new(:query => 'element', :affiliate => affiliate)
      @search.run
      puts @search.startrecord
    end
    
    it "should output a key based on the parameters" do
      @search.cache_key.should == "element:nps.gov:1"
    end
  end
  
  describe "#as_json" do
    before do
      @search = OdieSearch.new(:query => 'element', :affiliate => affiliate)
      @search.run
    end
    
    it "should generate a JSON representation of total, start and end records and search results" do
      json = @search.to_json
      json.should =~ /total/
      json.should =~ /startrecord/
      json.should =~ /endrecord/
    end

    context "when an error occurs" do
      before do
        @search.instance_variable_set(:@error_message, "Some error")
      end

      it "should output an error if an error is detected" do
        json = @search.to_json
        json.should =~ /"error":"Some error"/
      end
    end
  end
  
  describe "#to_xml" do
    before do
      @search = OdieSearch.new(:query => 'element', :affiliate => affiliate)
      @search.run
    end

    it "should generate an XML representation of total, start and end records and search results" do
      xml = @search.to_xml
      xml.should =~ /<total.*<\/total>/
      xml.should =~ /<startrecord.*<\/startrecord>/
      xml.should =~ /<endrecord.*<\/endrecord>/
    end

    context "when an error occurs" do
      before do
        @search.instance_variable_set(:@error_message, "Some error")
      end

      it "should output an error if an error is detected" do
        xml = @search.to_xml
        xml.should =~ /<error>Some error<\/error>/
      end
    end    
  end
end
