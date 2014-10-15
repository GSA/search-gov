require 'spec_helper'

describe BoostedContent do
  fixtures :affiliates
  before do
    @affiliate = affiliates(:usagov_affiliate)
    @valid_attributes = {
        :affiliate => @affiliate,
        :url => "http://www.someaffiliate.gov/foobar",
        :title => "The foobar page",
        :description => "All about foobar, boosted to the top",
        :status => 'active',
        :publish_start_on => Date.yesterday
    }
  end

  describe "Creating new instance of BoostedContent" do
    it { should validate_presence_of :url }
    it { should validate_presence_of :title }
    it { should validate_presence_of :description }
    it { should validate_presence_of :affiliate }
    it { should validate_presence_of :publish_start_on }

    BoostedContent::STATUSES.each do |status|
      it { should allow_value(status).for(:status) }
    end
    it { should_not allow_value("bogus status").for(:status) }

    specify { BoostedContent.new(:status => 'active').should be_is_active }
    specify { BoostedContent.new(:status => 'active').should_not be_is_inactive }
    specify { BoostedContent.new(:status => 'inactive').should be_is_inactive }
    specify { BoostedContent.new(:status => 'inactive').should_not be_is_active }

    it { should belong_to :affiliate }
    it { should have_many(:boosted_content_keywords).dependent(:destroy) }

    it "should create a new instance given valid attributes" do
      BoostedContent.create!(@valid_attributes)
    end

    it "should validate unique url" do
      BoostedContent.create!(@valid_attributes)
      duplicate = BoostedContent.new(@valid_attributes.merge(:url => @valid_attributes[:url].upcase))
      duplicate.should_not be_valid
      duplicate.errors[:url].first.should =~ /already been boosted/
    end

    it "should allow a duplicate url for a different affiliate" do
      BoostedContent.create!(@valid_attributes)
      duplicate = BoostedContent.new(@valid_attributes.merge(:affiliate => affiliates(:basic_affiliate)))
      duplicate.should be_valid
    end

    it "should not allow publish start date before publish end date" do
      boosted_content = BoostedContent.create(@valid_attributes.merge({ :publish_start_on => '07/01/2012', :publish_end_on => '07/01/2011' }))
      boosted_content.errors.full_messages.join.should =~ /Publish end date can't be before publish start date/
    end

    it 'should not allow duplicate url' do
      url = 'usasearch.howto.gov/post/9866782725/did-you-mean-roes-or-rose'
      BoostedContent.create!(@valid_attributes.merge(url: url))
      expect { BoostedContent.create!(@valid_attributes.merge(url: url)) }.to raise_error
    end

    it 'should not allow blank description' do
      expect { BoostedContent.create!(@valid_attributes.merge(description: '&nbsp;')) }.to raise_error
    end

    it "should save URL with http:// prefix when it does not start with http(s)://" do
      url = 'usasearch.howto.gov/post/9866782725/did-you-mean-roes-or-rose'
      prefixes = %w( http https invalidHtTp:// invalidhttps:// invalidHttPsS://)
      prefixes.each do |prefix|
        boosted_content = BoostedContent.create!(@valid_attributes.merge(:url => "#{prefix}#{url}"))
        boosted_content.url.should == "http://#{prefix}#{url}"
      end
    end

    it "should save URL as is when it starts with http(s)://" do
      url = 'usasearch.howto.gov/post/9866782725/did-you-mean-roes-or-rose'
      prefixes = %w( http:// HTTPS:// )
      prefixes.each do |prefix|
        boosted_content = BoostedContent.create!(@valid_attributes.merge(:url => "#{prefix}#{url}"))
        boosted_content.url.should == "#{prefix}#{url}"
      end
    end
  end

  describe '.substring_match(query)' do
    context 'when only the parent record has substring match in selected text fields' do
      before do
        common = {status: 'active', publish_start_on: Date.yesterday}
        @affiliate.boosted_contents.build(common.merge(url: 'http://www.abcd.gov/', title: 'my blah title', description: 'my blah description'))
        @affiliate.boosted_contents.build(common.merge(url: 'http://www.blah.gov/1', title: 'my second efgh title', description: 'my second blah description'))
        @affiliate.boosted_contents.build(common.merge(url: 'http://www.blah.gov/2', title: 'my third blah title', description: 'my third jkl description'))
        @affiliate.save!
      end

      it 'should find the records' do
        %w{bcd efg jk}.each do |substring|
          @affiliate.boosted_contents.substring_match(substring).size.should == 1
        end
        @affiliate.boosted_contents.substring_match('gov').size.should == 3
      end

      context 'when the keywords has substring match in selected fields' do
        before do
          BoostedContent.last.boosted_content_keywords.create!(:value => 'third')
          BoostedContent.last.boosted_content_keywords.create!(:value => 'thirdly')
        end

        it 'should find the record just once' do
          @affiliate.boosted_contents.substring_match('third').size.should == 1
        end
      end
    end

    context 'when keywords association has substring match in selected fields' do
      before do
        common = {status: 'active', publish_start_on: Date.yesterday}
        bc = @affiliate.boosted_contents.build(common.merge(url: 'http://www.abcd.gov/', title: 'my efgh title', description: 'my ijkl description'))
        bc.boosted_content_keywords.build(:value => 'pollution')
        bc.save!
      end

      it 'should find the records' do
        @affiliate.boosted_contents.substring_match('pollution').size.should == 1
      end
    end

    context 'when neither the parent or the child records match' do
      before do
        common = {status: 'active', publish_start_on: Date.yesterday}
        bc = @affiliate.boosted_contents.build(common.merge(url: 'http://www.abcd.gov/', title: 'my efgh title', description: 'my ijkl description'))
        bc.boosted_content_keywords.build(:value => 'pollution')
        bc.save!
      end

      it 'should not find any records' do
        @affiliate.boosted_contents.substring_match('sfgdfgdfgdfg').size.should be_zero
      end
    end
  end

  describe "#human_attribute_name" do
    specify { BoostedContent.human_attribute_name("publish_start_on").should == "Publish start date" }
    specify { BoostedContent.human_attribute_name("publish_end_on").should == "Publish end date" }
    specify { BoostedContent.human_attribute_name("url").should == "URL" }
  end

  describe "#as_json" do
    it "should include title, url, and description" do
      hash = BoostedContent.create!(@valid_attributes).as_json
      hash[:title].should == @valid_attributes[:title]
      hash[:url].should == @valid_attributes[:url]
      hash[:description].should == @valid_attributes[:description]
      hash.keys.length.should == 3
    end
  end

  describe "#to_xml" do
    it "should include title, url, and description" do
      hash = Hash.from_xml(BoostedContent.create!(@valid_attributes).to_xml)['boosted_result']
      hash['title'].should == @valid_attributes[:title]
      hash['url'].should == @valid_attributes[:url]
      hash['description'].should == @valid_attributes[:description]
      hash.keys.length.should == 3
    end
  end

  context "when the affiliate associated with a particular Boosted Content is destroyed" do
    before do
      affiliate = Affiliate.create!({ :display_name => "Test Affiliate", :name => 'test_affiliate' }, :as => :test)
      BoostedContent.create(@valid_attributes.merge(:affiliate => affiliate))
      affiliate.destroy
    end

    it "should also delete the boosted Content" do
      BoostedContent.find_by_url(@valid_attributes[:url]).should be_nil
    end
  end

  describe "#display_status" do
    context "when status is set to active" do
      subject { BoostedContent.new(:status => 'active') }
      its(:display_status) { should == 'Active' }
    end

    context "when status is set to inactive" do
      subject { BoostedContent.new(:status => 'inactive') }
      its(:display_status) { should == 'Inactive' }
    end
  end
end
