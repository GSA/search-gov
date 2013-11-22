require 'spec_helper'

describe BoostedContentBulkUploader do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:uploader) { BoostedContentBulkUploader.new(affiliate) }

  describe "#upload" do
    context "when the uploaded file has .png extension" do
      let(:png_file) { mock('png_file', { :original_filename => "boosted_content.png" }) }

      before do
        @results = uploader.upload(png_file)
      end

      subject { @results }
      specify { @results[:success].should be_false }
      specify { @results[:error_message].should == "Your filename should have .xml, .csv or .txt extension." }
    end

    context "when the bulk upload file parameter is nil" do

      before do
        @results = uploader.upload(nil)
      end

      subject { @results }
      specify { @results[:success].should be_false }
      specify { @results[:error_message].should == "Your document could not be processed. Please check the format and try again." }
    end

    context "when uploading an XML file" do
      let(:site_xml) {
        <<-XML
        <xml>
          <entries>
            <entry>
              <title>This is a listing about Texas</title>
              <url>http://some.url</url>
              <description>This is the description of the listing</description>
            </entry>
            <entry>
              <title>Some other listing about hurricanes</title>
              <url>http://some.other.url</url>
              <description>Another description for another listing</description>
            </entry>
          </entries>
        </xml>
        XML
      }

      let(:xml_file) { StringIO.new(site_xml) }

      before do
        affiliate.boosted_contents.destroy_all
        BoostedContent.reindex
        Sunspot.commit
        xml_file.stub(:original_filename).and_return "foo.xml"
      end

      it "should create and index boosted Contents from an xml document" do
        results = uploader.upload(xml_file)
        Sunspot.commit

        affiliate.reload
        affiliate.boosted_contents.length.should == 2
        affiliate.boosted_contents.map(&:url).should =~ %w{http://some.url http://some.other.url}
        affiliate.boosted_contents.all.find { |b| b.url == "http://some.other.url" }.description.should == "Another description for another listing"
        BoostedContent.solr_search_ids { with :affiliate_id, affiliate.id; paginate(:page => 1, :per_page => 10) }.should =~ affiliate.boosted_content_ids
        results[:success].should be_true
        results[:created].should == 2
        results[:updated].should == 0
      end

      it "should update existing boosted Contents if the url matches" do
        affiliate.boosted_contents.create!(:url => "http://some.url", :title => "an old title", :description => "an old description", :status => 'active', :publish_start_on => Date.current)
        results = uploader.upload(xml_file)
        Sunspot.commit

        affiliate.reload
        affiliate.boosted_contents.length.should == 2
        affiliate.boosted_contents.all.find { |b| b.url == "http://some.url" }.title.should == "This is a listing about Texas"
        results[:success].should be_true
        results[:created].should == 1
        results[:updated].should == 1
      end

      it "should merge with preexisting boosted Contents" do
        affiliate.boosted_contents.create!(:url => "http://a.different.url", :title => "title", :description => "description", :publish_start_on => Date.current, :status => 'active')
        results = uploader.upload(xml_file)
        Sunspot.commit

        affiliate.reload
        affiliate.boosted_contents.length.should == 3
        affiliate.boosted_contents.map(&:url).should =~ %w{http://some.url http://some.other.url http://a.different.url}
        results[:success].should be_true
        results[:created].should == 2
        results[:updated].should == 0
      end

      it "should not update existing boosted Contents if one of the imports failed" do
        affiliate.boosted_contents.create!(:url => "http://some.other.url", :title => "an old title", :description => "an old description", :status => 'active', :publish_start_on => Date.current)
        BoostedContent.reindex
        Sunspot.commit
        bc = BoostedContent.new(:title => 'This is a listing about Texas',
                                :url => 'http://some.url',
                                :description => 'This is the description of the listing',
                                :status => 'active', :publish_start_on => Date.current)

        BoostedContent.should_receive(:find_or_initialize_by_url).with(hash_including(:url => 'http://some.url')).and_return(bc)

        BoostedContent.should_receive(:find_or_initialize_by_url).with(hash_including(:url => 'http://some.other.url')).
            and_raise(ActiveRecord::RecordInvalid.new(bc))

        results = uploader.upload(xml_file)
        Sunspot.commit

        results[:success].should be_false
        affiliate.reload
        affiliate.boosted_contents.length.should == 1
        affiliate.boosted_contents.all.find { |b| b.url == "http://some.other.url" }.title.should == "an old title"
        BoostedContent.solr_search_ids { with :affiliate_id, affiliate.id; paginate(:page => 1, :per_page => 10) }.length.should == 1
      end
    end
    
    context "when uploading a CSV file" do
      let(:site_csv) {
        <<-CSV
This is a listing about Texas,http://some.url,This is the description of the listing

Some other listing about hurricanes,http://some.other.url,Another description for another listing

        CSV
      }

      let(:csv_file) { StringIO.new(site_csv) }

      before do
        affiliate.boosted_contents.destroy_all
        BoostedContent.reindex
        Sunspot.commit
        csv_file.stub(:original_filename).and_return "foo.csv"
      end

      it "should create and index boosted Contents from an csv document" do
        results = uploader.upload(csv_file)
        Sunspot.commit

        affiliate.reload
        affiliate.boosted_contents.length.should == 2
        affiliate.boosted_contents.map(&:url).should =~ %w{http://some.url http://some.other.url}
        affiliate.boosted_contents.all.find { |b| b.url == "http://some.other.url" }.description.should == "Another description for another listing"
        BoostedContent.solr_search_ids { with :affiliate_id, affiliate.id; paginate(:page => 1, :per_page => 10) }.should =~ affiliate.boosted_content_ids
        results[:success].should be_true
        results[:created].should == 2
        results[:updated].should == 0
      end

      it "should update existing boosted Contents if the url match" do
        affiliate.boosted_contents.create!(:url => "http://some.url", :title => "an old title", :description => "an old description", :status => 'active', :publish_start_on => Date.current)

        results = uploader.upload(csv_file)

        affiliate.reload
        affiliate.boosted_contents.length.should == 2
        affiliate.boosted_contents.all.find { |b| b.url == "http://some.url" }.title.should == "This is a listing about Texas"
        results[:success].should be_true
        results[:created].should == 1
        results[:updated].should == 1
      end

      it "should merge with preexisting boosted Contents" do
        affiliate.boosted_contents.create!(:url => "http://a.different.url", :title => "title", :description => "description", :status => 'active', :publish_start_on => Date.current)

        results = uploader.upload(csv_file)

        affiliate.reload
        affiliate.boosted_contents.length.should == 3
        affiliate.boosted_contents.map(&:url).should =~ %w{http://some.url http://some.other.url http://a.different.url}
        results[:success].should be_true
        results[:created].should == 2
        results[:updated].should == 0
      end

      it "should not update existing boosted Contents if one of the imports failed" do
        affiliate.boosted_contents.create!(:url => "http://some.other.url", :title => "an old title", :description => "an old description", :status => 'active', :publish_start_on => Date.current)
        bc = BoostedContent.new(:title => 'This is a listing about Texas',
                                :url => 'http://some.url',
                                :description => 'This is the description of the listing',
                                :status => 'active', :publish_start_on => Date.current)
        BoostedContent.should_receive(:find_or_initialize_by_url).with(hash_including(:url => 'http://some.url')).and_return(bc)

        BoostedContent.should_receive(:find_or_initialize_by_url).with(hash_including(:url => 'http://some.other.url')).
            and_raise(ActiveRecord::RecordInvalid.new(bc))

        results = uploader.upload(csv_file)

        results[:success].should be_false
        affiliate.reload
        affiliate.boosted_contents.length.should == 1
        affiliate.boosted_contents.all.find { |b| b.url == "http://some.other.url" }.title.should == "an old title"
      end
    end
  end
end