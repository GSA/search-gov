require 'spec/spec_helper'

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
    it { should validate_uniqueness_of(:url).scoped_to(:affiliate_id) }
    it { should belong_to(:affiliate) }
  end
end
