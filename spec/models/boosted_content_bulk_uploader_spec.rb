require 'spec_helper'

describe BoostedContentBulkUploader do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:uploader) { BoostedContentBulkUploader.new(affiliate) }

  before do
    ElasticBoostedContent.recreate_index
  end

  describe "#upload" do
    context "when the uploaded file has .png extension" do
      let(:png_file) { mock('png_file', { :original_filename => "boosted_content.png" }) }

      before do
        @results = uploader.upload(png_file)
      end

      subject { @results }
      specify { @results[:success].should be_false }
      specify { @results[:error_message].should == 'Your filename should have .csv or .txt extension.' }
    end

    context "when the bulk upload file parameter is nil" do

      before do
        @results = uploader.upload(nil)
      end

      subject { @results }
      specify { @results[:success].should be_false }
      specify { @results[:error_message].should == "Your document could not be processed. Please check the format and try again." }
    end

    context "when uploading a CSV file" do
      let(:site_csv) {
        <<-CSV
This is a listing    about Texas,http://some.url,This is the description of the listing,2014-01-01,2022-03-21,"Texan, ,Lone  Star "

Some other listing about hurricanes,http://some.other.url,Another   description for another listing

        CSV
      }

      let(:csv_file) { StringIO.new(site_csv) }
      let(:current_date) { Date.parse('2014-01-01') }

      before do
        affiliate.boosted_contents.destroy_all
        csv_file.stub(:original_filename).and_return "foo.csv"
        Date.stub(:current) { current_date }
      end

      it "should create and index boosted Contents from an csv document" do
        results = uploader.upload(csv_file)

        affiliate.reload
        affiliate.boosted_contents.length.should == 2
        affiliate.boosted_contents.map(&:url).should =~ %w{http://some.url http://some.other.url}
        affiliate.boosted_contents.all.find { |b| b.url == "http://some.other.url" }.description.should == "Another description for another listing"

        texas_boosted_content = affiliate.boosted_contents.find_by_url 'http://some.url'
        texas_boosted_content.title.should == 'This is a listing about Texas'
        texas_boosted_content.publish_start_on.should == current_date
        texas_boosted_content.publish_end_on.should == Date.parse('2022-03-21')
        texas_boosted_content.boosted_content_keywords.pluck(:value).should == ['Lone Star', 'Texan']

        results[:success].should be_true
        results[:created].should == 2
        results[:updated].should == 0
      end

      it "should update existing boosted Contents if the url match" do
        boosted_content = affiliate.boosted_contents.build(
            url: "http://some.url",
            title: "an old title",
            description: "an old description",
            status: 'active',
            publish_start_on: Date.current)
        boosted_content.boosted_content_keywords.build(value: 'Lone star state')
        boosted_content.boosted_content_keywords.build(value: 'Texan')
        boosted_content.save!

        results = uploader.upload(csv_file)

        affiliate.reload
        affiliate.boosted_contents.length.should == 2
        affiliate.boosted_contents.all.find { |b| b.url == "http://some.url" }.title.should == "This is a listing about Texas"

        boosted_content = affiliate.boosted_contents.find(boosted_content.id)
        boosted_content.publish_end_on.should == Date.parse('2022-03-21')
        boosted_content.boosted_content_keywords.pluck(:value).should == ['Lone Star', 'Texan']
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

    end
  end
end
