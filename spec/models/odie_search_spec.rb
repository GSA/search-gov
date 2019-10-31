require 'spec_helper'

describe OdieSearch do
  fixtures :affiliates, :features

  let(:affiliate) { affiliates(:basic_affiliate) }

  before do
    ElasticIndexedDocument.recreate_index
    affiliate.indexed_documents.create!(:url => 'http://nps.gov/something.pdf', :title => 'The Fifth Element',
                                        :description => 'Leeloo the supreme being',
                                        :body => 'other esoteric content related to the document somehow',
                                        :last_crawled_at => Time.now, :last_crawl_status => "OK")
    ElasticIndexedDocument.commit
  end

  describe "#initialize(options)" do
    context "when the query param isn't set" do
      it "should set 'query' to a blank string" do
        expect(OdieSearch.new(:affiliate => affiliate).query).to be_blank
      end
    end
  end

  describe "#run" do
    context "when searching with really long queries" do
      before do
        @search = OdieSearch.new({:query => "X" * (Search::MAX_QUERYTERM_LENGTH + 1), :affiliate => affiliate})
      end

      it "should return false when searching" do
        expect(@search.run).to be false
      end

      it "should have 0 results" do
        @search.run
        expect(@search.results.size).to eq(0)
        expect(@search.total).to eq(0)
        expect(@search.module_tag).to be_nil
      end

      it "should set error message" do
        @search.run
        expect(@search.error_message).not_to be_nil
      end
    end

    context "when searching with a blank query" do
      before do
        @search = OdieSearch.new({:query => "   ", :affiliate => affiliate})
      end

      it "should return false when searching" do
        expect(@search.run).to be false
      end

      it "should have 0 results" do
        @search.run
        expect(@search.results.size).to eq(0)
      end

      it "should set error message" do
        @search.run
        expect(@search.error_message).not_to be_nil
      end
    end

    context 'when result body has the hit highlight, not the description' do
      it 'returns the body hit as the description' do
        search = OdieSearch.new(query: "supreme", affiliate: affiliate)
        search.run
        expect(search.results.first['content']).to match(/\xEE\x80\x80supreme\xEE\x80\x81/)
        search = OdieSearch.new(query: "esoteric", affiliate: affiliate)
        search.run
        expect(search.results.first['content']).to match(/\xEE\x80\x80esoteric\xEE\x80\x81/)
        search = OdieSearch.new(query: "fifth", affiliate: affiliate)
        search.run
        expect(search.results.first['content']).to eq('Leeloo the supreme being')
      end
    end
  end

  describe "#cache_key" do
    before do
      @dc = affiliate.document_collections.create!(:name => "whatevs",
                                                   :url_prefixes_attributes => {'0' => { :prefix => 'https://www.usa.gov/docs/' } })
      @dc.navigation.update_attributes!(:is_active => true)
    end

    it "should output a key based on the query, affiliate id, doc collection, and page parameters" do
      expect(OdieSearch.new(:query => 'element', :affiliate => affiliate, :page => 4, :document_collection => @dc).cache_key).to eq("element:#{affiliate.id}:4:#{@dc.id}")
      expect(OdieSearch.new(:query => 'element', :affiliate => affiliate, :page => 4).cache_key).to eq("element:#{affiliate.id}:4:")
    end
  end

  describe "#as_json" do
    before do
      @search = OdieSearch.new(:query => 'element', :affiliate => affiliate)
      @search.run
    end

    it "should always generate a JSON representation of total, start and end records, and search results" do
      json = @search.to_json
      expect(json).to match(/total/)
      expect(json).to match(/startrecord/)
      expect(json).to match(/endrecord/)
    end

    context "when an error occurs" do
      before do
        @search.instance_variable_set(:@error_message, "Some error")
      end

      it "should output an error if an error is detected" do
        json = @search.to_json
        expect(json).to match(/"error":"Some error"/)
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
      expect(xml).to match(/<total.*<\/total>/)
      expect(xml).to match(/<startrecord.*<\/startrecord>/)
      expect(xml).to match(/<endrecord.*<\/endrecord>/)
    end

    context "when an error occurs" do
      before do
        @search.instance_variable_set(:@error_message, "Some error")
      end

      it "should output an error if an error is detected" do
        xml = @search.to_xml
        expect(xml).to match(/<error>Some error<\/error>/)
      end
    end
  end
end
