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
      let(:file) { double('png_file', { :original_filename => "boosted_content.png" }) }

      specify { expect(results[:success]).to be false }
      specify { expect(results[:error_message]).to eq('Your filename should have .csv or .txt extension.') }
    end

    context "when the bulk upload file parameter is nil" do
      let(:file) { nil }

      specify { expect(results[:success]).to be false }
      specify { expect(results[:error_message]).to eq("Your document could not be processed. Please check the format and try again.") }
    end

    context "when uploading a CSV file" do
      before { affiliate.boosted_contents.destroy_all }

      it "should create and index boosted Contents from a csv document" do
        results

        affiliate.reload
        expect(affiliate.boosted_contents.length).to eq(3)
        expect(affiliate.boosted_contents.map(&:url)).to match_array(%w{http://some.url http://www.texas.gov http://some.other.url})
        expect(affiliate.boosted_contents.all.find { |b| b.url == "http://some.other.url" }.description).to eq("Another description for another listing")

        texas_boosted_content = affiliate.boosted_contents.find_by_url 'http://some.url'
        expect(texas_boosted_content.title).to eq('This is a listing about Texas')
        expect(texas_boosted_content.publish_start_on).to eq(Date.parse('2019-01-01'))
        expect(texas_boosted_content.publish_end_on).to eq(Date.parse('2022-03-21'))
        expect(texas_boosted_content.boosted_content_keywords.pluck(:value)).to eq(['Lone Star', 'Texan'])
        expect(texas_boosted_content.match_keyword_values_only).to be true
        expect(affiliate.boosted_contents.where(status: 'active').pluck(:url)).to match_array(["http://some.other.url", "http://some.url"])

        texas_boosted_content_keywords_only = affiliate.boosted_contents.find_by_url 'http://www.texas.gov'
        expect(texas_boosted_content_keywords_only.match_keyword_values_only).to be false # because there we no keywords provided

        expect(results[:success]).to be true
        expect(results[:created]).to eq(3)
        expect(results[:updated]).to eq(0)
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
        expect(affiliate.boosted_contents.length).to eq(3)
        expect(affiliate.boosted_contents.all.find { |b| b.url == "http://some.url" }.title).to eq("This is a listing about Texas")

        boosted_content = affiliate.boosted_contents.find(boosted_content.id)
        expect(boosted_content.publish_start_on).to eq(Date.parse('2019-01-01'))
        expect(boosted_content.publish_end_on).to eq(Date.parse('2022-03-21'))
        expect(boosted_content.boosted_content_keywords.pluck(:value)).to eq(['Lone Star', 'Texan'])
        expect(boosted_content.match_keyword_values_only).to be true
        expect(results[:success]).to be true
        expect(results[:created]).to eq(2)
        expect(results[:updated]).to eq(1)
      end

      it "should merge with preexisting boosted Contents" do
        affiliate.boosted_contents.create!(:url => "http://a.different.url", :title => "title", :description => "description", :status => 'active', :publish_start_on => Date.current)

        results

        affiliate.reload
        expect(affiliate.boosted_contents.length).to eq(4)

        expect(results[:success]).to be true
        expect(results[:created]).to eq(3)
        expect(results[:updated]).to eq(0)
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

      context 'when the urls are malformed' do
        let(:file) { fixture_file_upload('/csv/boosted_content/bad_urls.csv', 'text/csv') }

        it 'does not create boosted content with bad urls' do
          expect(results[:created]).to eq 1
        end

        it 'counts the failures' do
          expect(results[:failed]).to eq 3
        end
      end
    end
  end

  # Test this particular private method to ensure that it parses booleans
  # correctly when they appear in the match_keyword_values_only field.
  describe '#extract_bool' do
    %w[ true True Yes Y y 1 tRue ].each do |v|
       specify { expect(uploader.send(:extract_bool, v)).to be_truthy }
    end

    ([ nil, '' ] + %w[ false 0 no No fAlse nope whatever ]).each do |v|
       specify { expect(uploader.send(:extract_bool, v)).to be_falsey }
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
