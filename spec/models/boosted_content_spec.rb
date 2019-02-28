require 'spec_helper'

describe BoostedContent do
  fixtures :affiliates, :languages
  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:valid_attributes) do
    { :affiliate => affiliate,
      :url => "http://www.someaffiliate.gov/foobar",
      :title => "The foobar page",
      :description => "All about foobar, boosted to the top",
      :status => 'active',
      :publish_start_on => Date.yesterday }
  end

  describe "Creating new instance of BoostedContent" do
    it { is_expected.to validate_presence_of :url }
    it { is_expected.to validate_presence_of :title }
    it { is_expected.to validate_presence_of :description }
    it { is_expected.to validate_presence_of :affiliate }
    it { is_expected.to validate_presence_of :publish_start_on }

    it 'validates the url format' do
      boosted_content = BoostedContent.new(url: 'blah')
      expect(boosted_content).to_not be_valid
      expect(boosted_content.errors[:url]).to include(" - Please ensure the URLs are properly formatted, including the http:// or https:// prefix.")
    end

    BoostedContent::STATUSES.each do |status|
      it { is_expected.to allow_value(status).for(:status) }
    end
    it { is_expected.not_to allow_value("bogus status").for(:status) }

    specify { expect(BoostedContent.new(:status => 'active')).to be_is_active }
    specify { expect(BoostedContent.new(:status => 'active')).not_to be_is_inactive }
    specify { expect(BoostedContent.new(:status => 'inactive')).to be_is_inactive }
    specify { expect(BoostedContent.new(:status => 'inactive')).not_to be_is_active }

    it { is_expected.to belong_to :affiliate }
    it { is_expected.to have_many(:boosted_content_keywords).dependent(:destroy) }

    it "should create a new instance given valid attributes" do
      BoostedContent.create!(valid_attributes)
    end

    it "should validate unique url" do
      BoostedContent.create!(valid_attributes)
      duplicate = BoostedContent.new(valid_attributes.merge(:url => valid_attributes[:url].upcase))
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:url].first).to match(/already been boosted/)
    end

    it "should allow a duplicate url for a different affiliate" do
      BoostedContent.create!(valid_attributes)
      duplicate = BoostedContent.new(valid_attributes.merge(:affiliate => affiliates(:basic_affiliate)))
      expect(duplicate).to be_valid
    end

    it "should not allow publish start date before publish end date" do
      boosted_content = BoostedContent.create(valid_attributes.merge({ :publish_start_on => '07/01/2012', :publish_end_on => '07/01/2011' }))
      expect(boosted_content.errors.full_messages.join).to match(/Publish end date can't be before publish start date/)
    end

    it 'should not allow duplicate url' do
      url = 'http://search.gov/post/9866782725/did-you-mean-roes-or-rose'
      BoostedContent.create!(valid_attributes.merge(url: url))
      expect { BoostedContent.create!(valid_attributes.merge(url: url)) }.to raise_error
    end

    it 'should not allow blank description' do
      expect { BoostedContent.create!(valid_attributes.merge(description: '&nbsp;')) }.to raise_error
    end

    it "should save URL as is when it starts with http(s)://" do
      url = 'search.gov/post/9866782725/did-you-mean-roes-or-rose'
      prefixes = %w( http:// HTTPS:// )
      prefixes.each do |prefix|
        boosted_content = BoostedContent.create!(valid_attributes.merge(:url => "#{prefix}#{url}"))
        expect(boosted_content.url).to eq("#{prefix}#{url}")
      end
    end
  end

  describe 'match_keyword_values_only validation' do
    context 'when no boosted_content_keywords are provided' do
      it 'should not allow match_keyword_values_only to be set to true' do
        boosted_content = BoostedContent.create(valid_attributes.merge({ :match_keyword_values_only => true }))
        expect(boosted_content.errors.full_messages.join).to match(/requires at least one keyword/)
      end
    end

    context 'when some boosted_content_keywords are provided' do
      it 'should not allow match_keyword_values_only to be set to true' do
        boosted_content = affiliate.boosted_contents.build(valid_attributes.merge({ match_keyword_values_only: true }))
        boosted_content.boosted_content_keywords.build({ value: 'foo bar' })
        expect(boosted_content).to be_valid
      end
    end
  end

  describe '.substring_match(query)' do
    context 'when only the parent record has substring match in selected text fields' do
      before do
        common = {status: 'active', publish_start_on: Date.yesterday}
        affiliate.boosted_contents.build(common.merge(url: 'http://www.abcd.gov/', title: 'my blah title', description: 'my blah description'))
        affiliate.boosted_contents.build(common.merge(url: 'http://www.blah.gov/1', title: 'my second efgh title', description: 'my second blah description'))
        affiliate.boosted_contents.build(common.merge(url: 'http://www.blah.gov/2', title: 'my third blah title', description: 'my third jkl description'))
        affiliate.save!
      end

      it 'should find the records' do
        %w{bcd efg jk}.each do |substring|
          expect(affiliate.boosted_contents.substring_match(substring).size).to eq(1)
        end
        expect(affiliate.boosted_contents.substring_match('gov').size).to eq(3)
      end

      context 'when the keywords has substring match in selected fields' do
        before do
          BoostedContent.last.boosted_content_keywords.create!(:value => 'third')
          BoostedContent.last.boosted_content_keywords.create!(:value => 'thirdly')
        end

        it 'should find the record just once' do
          expect(affiliate.boosted_contents.substring_match('third').size).to eq(1)
        end
      end
    end

    context 'when keywords association has substring match in selected fields' do
      before do
        common = {status: 'active', publish_start_on: Date.yesterday}
        bc = affiliate.boosted_contents.build(common.merge(url: 'http://www.abcd.gov/', title: 'my efgh title', description: 'my ijkl description'))
        bc.boosted_content_keywords.build(:value => 'pollution')
        bc.save!
      end

      it 'should find the records' do
        expect(affiliate.boosted_contents.substring_match('pollution').size).to eq(1)
      end
    end

    context 'when neither the parent or the child records match' do
      before do
        common = {status: 'active', publish_start_on: Date.yesterday}
        bc = affiliate.boosted_contents.build(common.merge(url: 'http://www.abcd.gov/', title: 'my efgh title', description: 'my ijkl description'))
        bc.boosted_content_keywords.build(:value => 'pollution')
        bc.save!
      end

      it 'should not find any records' do
        expect(affiliate.boosted_contents.substring_match('sfgdfgdfgdfg').size).to be_zero
      end
    end
  end

  describe "#human_attribute_name" do
    specify { expect(BoostedContent.human_attribute_name("publish_start_on")).to eq("Publish start date") }
    specify { expect(BoostedContent.human_attribute_name("publish_end_on")).to eq("Publish end date") }
    specify { expect(BoostedContent.human_attribute_name("url")).to eq("URL") }
  end

  describe "#as_json" do
    it "should include title, url, and description" do
      hash = BoostedContent.create!(valid_attributes).as_json
      expect(hash[:id]).not_to be_nil
      expect(hash[:title]).to eq(valid_attributes[:title])
      expect(hash[:url]).to eq(valid_attributes[:url])
      expect(hash[:description]).to eq(valid_attributes[:description])
      expect(hash.keys.length).to eq(4)
    end
  end

  describe "#to_xml" do
    it "should include title, url, and description" do
      hash = Hash.from_xml(BoostedContent.create!(valid_attributes).to_xml)['boosted_result']
      expect(hash['title']).to eq(valid_attributes[:title])
      expect(hash['url']).to eq(valid_attributes[:url])
      expect(hash['description']).to eq(valid_attributes[:description])
      expect(hash.keys.length).to eq(3)
    end
  end

  context 'when the affiliate associated with a ' \
          'particular Boosted Content is destroyed' do
    before do
      affiliate = Affiliate.create!(display_name: 'Test Affiliate',
                                    name: 'test_affiliate')
      BoostedContent.create(valid_attributes.merge(affiliate: affiliate))
      affiliate.destroy
    end

    it "should also delete the boosted Content" do
      expect(BoostedContent.find_by_url(valid_attributes[:url])).to be_nil
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
