require 'spec_helper'

describe MobileNavigationsHelper do
  fixtures :affiliates, :instagram_profiles

  describe "#site_has_navigable_image_vertical?(site)" do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    context 'when site has force_mobile_format=true, no flickr profiles, 1+ instagram profiles, and no bing image search enabled' do
      before do
        affiliate.instagram_profiles << instagram_profiles(:whitehouse)
        affiliate.force_mobile_format = true
        affiliate.flickr_profiles.delete_all
        affiliate.is_bing_image_search_enabled = false
        affiliate.save!
      end

      it 'should be true' do
        helper.site_has_navigable_image_vertical?(affiliate).should be_true
      end
    end
  end
end
