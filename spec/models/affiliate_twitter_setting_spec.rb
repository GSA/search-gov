require 'spec_helper'

describe AffiliateTwitterSetting do
  fixtures :affiliates, :twitter_profiles

  describe '#dup' do
    subject(:original_instance) do
      described_class.create!(affiliate_id: affiliates(:usagov_affiliate).id,
                                      twitter_profile_id: twitter_profiles(:usagov).id)
    end

    include_examples 'site dupable'
  end
end
