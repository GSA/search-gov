require 'spec_helper'

describe OdieSearch do
  fixtures :affiliates, :features

  let(:affiliate) { affiliates(:basic_affiliate) }

  before do
    affiliate.features << features(:hosted_sitemaps)

    affiliate.indexed_documents.create!(:url => 'http://nps.gov/something.pdf', :title => 'The Fifth Element', :description => 'Leeloo the supreme being', :last_crawled_at => Time.now, :last_crawl_status => "OK")
    IndexedDocument.reindex
  end

  describe "#initialize(options)" do
    context "when the query param isn't set" do
      it "should set 'query' to a blank string" do
        OdieSearch.new(:affiliate => affiliate).query.should be_blank
      end
    end
  end

  describe "#run" do
    it "should log info about the query and module impressions" do
      search = OdieSearch.new(:query => 'element', :affiliate => affiliate)
      QueryImpression.should_receive(:log).with(:odie, affiliate.name, 'element', ["AIDOC"])
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
      @dc = affiliate.document_collections.create!(:name => "whatevs",
                                                   :url_prefixes_attributes => {'0' => { :prefix => 'http://www.usa.gov/docs/' } })
      @dc.navigation.update_attributes!(:is_active => true)
    end

    it "should output a key based on the query, affiliate id, doc collection, and page parameters" do
      OdieSearch.new(:query => 'element', :affiliate => affiliate, :page => 4, :document_collection => @dc).cache_key.should == "element:#{affiliate.id}:4:#{@dc.id}"
      OdieSearch.new(:query => 'element', :affiliate => affiliate, :page => 4).cache_key.should == "element:#{affiliate.id}:4:"
    end
  end

  describe "#as_json" do
    before do
      @search = OdieSearch.new(:query => 'element', :affiliate => affiliate)
      @search.run
    end

    it "should always generate a JSON representation of total, start and end records, related searches, and search results" do
      json = @search.to_json
      json.should =~ /total/
      json.should =~ /startrecord/
      json.should =~ /endrecord/
      json.should =~ /related/
    end

    context "when related searches are present" do
      before do
        @search.instance_variable_set(:@related_search, ["<strong>foo</strong>", "<strong>foo</strong> is here <strong>again</strong>"])
      end

      it "should remove <strong> HTML formatting" do
        @search.as_json[:related].should == ["foo", "foo is here again"]
      end
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
