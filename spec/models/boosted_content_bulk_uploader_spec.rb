require 'spec_helper'

describe BoostedContentBulkUploader do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:file) { fixture_file_upload("/csv/boosted_content/bulk_upload.csv", 'text/csv') }
  let(:uploader) { BoostedContentBulkUploader.new(affiliate, file) }
  subject(:results) { uploader.upload }

  before do
    ElasticBoostedContent.recreate_index
    extend ActionDispatch::TestProcess
  end

  describe "#upload" do
    context "when the uploaded file has .png extension" do
      let(:file) { mock('png_file', { :original_filename => "boosted_content.png" }) }

      specify { results[:success].should be_false }
      specify { results[:error_message].should == 'Your filename should have .csv or .txt extension.' }
    end

    context "when the bulk upload file parameter is nil" do
      let(:file) { nil }

      specify { results[:success].should be_false }
      specify { results[:error_message].should == "Your document could not be processed. Please check the format and try again." }
    end

    context "when uploading a CSV file" do
      before { affiliate.boosted_contents.destroy_all }

      it "should create and index boosted Contents from a csv document" do
        results

        affiliate.reload
        affiliate.boosted_contents.length.should == 3
        affiliate.boosted_contents.map(&:url).should =~ %w{http://some.url http://www.texas.gov http://some.other.url}
        affiliate.boosted_contents.all.find { |b| b.url == "http://some.other.url" }.description.should == "Another description for another listing"

        texas_boosted_content = affiliate.boosted_contents.find_by_url 'http://some.url'
        texas_boosted_content.title.should == 'This is a listing about Texas'
        texas_boosted_content.publish_start_on.should == Date.parse('2019-01-01')
        texas_boosted_content.publish_end_on.should == Date.parse('2022-03-21')
        texas_boosted_content.boosted_content_keywords.pluck(:value).should == ['Lone Star', 'Texan']
        texas_boosted_content.match_keyword_values_only.should be_true
        affiliate.boosted_contents.where(status: 'active').pluck(:url).should =~ ["http://some.other.url", "http://some.url"]

        texas_boosted_content_keywords_only = affiliate.boosted_contents.find_by_url 'http://www.texas.gov'
        texas_boosted_content_keywords_only.match_keyword_values_only.should be_false # because there we no keywords provided

        results[:success].should be_true
        results[:created].should == 3
        results[:updated].should == 0
      end

      it "should update existing boosted Contents if the url match" do
        boosted_content = affiliate.boosted_contents.build(
            url: "http://some.url",
            title: "an old title",
            description: "an old description",
            status: 'active',
            publish_start_on: Date.current,
            match_keyword_values_only: false)
        boosted_content.boosted_content_keywords.build(value: 'Lone star state')
        boosted_content.boosted_content_keywords.build(value: 'Texan')
        boosted_content.save!

        results

        affiliate.reload
        affiliate.boosted_contents.length.should == 3
        affiliate.boosted_contents.all.find { |b| b.url == "http://some.url" }.title.should == "This is a listing about Texas"

        boosted_content = affiliate.boosted_contents.find(boosted_content.id)
        boosted_content.publish_start_on.should == Date.parse('2019-01-01')
        boosted_content.publish_end_on.should == Date.parse('2022-03-21')
        boosted_content.boosted_content_keywords.pluck(:value).should == ['Lone Star', 'Texan']
        boosted_content.match_keyword_values_only.should be_true
        results[:success].should be_true
        results[:created].should == 2
        results[:updated].should == 1
      end

      it "should merge with preexisting boosted Contents" do
        affiliate.boosted_contents.create!(:url => "http://a.different.url", :title => "title", :description => "description", :status => 'active', :publish_start_on => Date.current)

        results

        affiliate.reload
        affiliate.boosted_contents.length.should == 4

        results[:success].should be_true
        results[:created].should == 3
        results[:updated].should == 0
      end

      context 'when the file contains funky characters' do
        let(:file) do
          fixture_file_upload("/csv/boosted_content/with_funky_characters.csv", 'text/csv')
        end

        it 'successfully creates the boosted contents' do
          expect(results[:created]).to eq 1
          expect(affiliate.boosted_contents.first.description).to match /savers credit/
        end
      end

      context 'when a url is missing the http://' do
        let(:file) do
          fixture_file_upload("/csv/boosted_content/without_http.csv", "text/csv")
        end

        it 'recognizes the url with or without the http' do
          expect(results[:created]).to eq 1
          expect(results[:updated]).to eq 1
        end
      end

      context 'when the file contains a header row' do 
        let(:file) { fixture_file_upload('/csv/boosted_content/with_header.csv', 'text/csv') }

        it 'does not import the header row' do
          expect(results[:created]).to eq 1
          expect(affiliate.boosted_contents.first.title).to eq "Can I Take My Fireworks on a Plane?"
        end
      end

      context 'when the file contains blank lines' do 
        let(:file) { fixture_file_upload('/csv/boosted_content/with_blanks.csv', 'text/csv') }

        it 'skips the blanks' do
          expect(results[:created]).to eq 2
          expect(affiliate.boosted_contents.map(&:url)).to match_array %w{http://www.foo.com http://www.bar.com}
        end
      end
    end
  end

  # Test this particular private method to ensure that it parses booleans
  # correctly when they appear in the match_keyword_values_only field.
  describe '#extract_bool' do
    %w[ true True Yes Y y 1 tRue ].each do |v|
       specify { uploader.send(:extract_bool, v).should be_true }
    end

    ([ nil, '' ] + %w[ false 0 no No fAlse nope whatever ]).each do |v|
       specify { uploader.send(:extract_bool, v).should be_false }
    end
  end

  #...which seemed reasonable, so:
  describe '#extract_status' do
    it 'extracts the status' do
    ([ nil, '' ] + %w[ 1 active Active anything ]).each do |status|
      extracted_status = uploader.send(:extract_status, status)
      expect(extracted_status).to eq 'active'
    end

    %w[ 0 inactive Inactive ].each do |status|
      extracted_status = uploader.send(:extract_status, status)
      expect(extracted_status).to eq 'inactive'
    end
    end
  end
end
