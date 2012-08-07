require 'spec_helper'

describe AffiliateFeatureAddition do
  fixtures :affiliate_feature_additions, :features, :affiliates

  let(:valid_attributes) { {:affiliate_id => affiliates(:power_affiliate).id, :feature_id => features(:disco).id} }

  describe "creating a new AffiliateFeatureAddition" do
    it { should validate_presence_of :affiliate_id }
    it { should validate_presence_of :feature_id }
    it { should validate_uniqueness_of(:affiliate_id).scoped_to(:feature_id) }
    it { should belong_to(:affiliate) }
    it { should belong_to(:feature) }
    it "should create a new instance given valid attributes" do
      AffiliateFeatureAddition.create!(valid_attributes)
    end
  end
end
