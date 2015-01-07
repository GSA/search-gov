require 'spec_helper'

describe ExcludedUrl do
  fixtures :affiliates

  before do
    @valid_attributes = {
      :url => 'http://usa.gov/excludeme.html',
      :affiliate_id => affiliates(:basic_affiliate).id
    }
  end

  context "when creating a new excluded url" do
    before do
      ExcludedUrl.create!(@valid_attributes)
    end

    it { should validate_presence_of :url }
    it { should validate_uniqueness_of(:url).scoped_to(:affiliate_id).case_insensitive }
    it { should belong_to(:affiliate) }

    it 'should decode the URL' do
      excluded_url = ExcludedUrl.create!(@valid_attributes.merge(:url => "http://www.usa.gov/exclude%20me.html"))
      excluded_url.url.should == "http://www.usa.gov/exclude me.html"
    end
  end
end
