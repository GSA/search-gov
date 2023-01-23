# frozen_string_literal: true

describe TwitterList do
  let(:twitter_profile1) { twitter_profiles(:usagov) }
  let(:twitter_profile2) { twitter_profiles(:usasearch) }
  let(:twitter_list) do
    twitter_profile1.twitter_lists.create(member_ids: [twitter_profile2.twitter_id])
  end

  describe 'schema' do
    it { is_expected.to have_db_column(:safe_member_ids).of_type(:json) }
  end

  it { is_expected.to validate_numericality_of(:id).only_integer }
  it 'should not allow id = 0' do
    expect(described_class.new(id: 0)).not_to be_valid
  end
  it { is_expected.to have_and_belong_to_many :twitter_profiles }

  describe '.member_ids' do
    subject(:member_ids) { twitter_list.member_ids }

    it 'returns an array of Twitter profile twitter_ids' do
      expect(member_ids).to eq [260266634]
    end
  end

  describe '.active' do
    let(:a1) { affiliates(:usagov_affiliate) }
    let(:a2) { affiliates(:basic_affiliate) }
    let(:tl1) { described_class.create(id: 1) }
    let(:tl2) { described_class.create(id: 2) }

    before do
      twitter_profile1.twitter_lists << tl1; twitter_profile1.save!
      twitter_profile2.twitter_lists << tl2; twitter_profile2.save!
      AffiliateTwitterSetting.create(affiliate: a1, twitter_profile: twitter_profile1, show_lists: 1)
      AffiliateTwitterSetting.create(affiliate: a2, twitter_profile: twitter_profile2, show_lists: 0)
    end

    it 'returns only the lists belonging to affiliates whose twitter settings indicate that lists should be shown' do
      expect(described_class.active).to eq([tl1])
    end
  end

  describe '.statuses_updated_before' do
    subject(:sub) { described_class.statuses_updated_before(Time.zone.now - 1.hour) }
    let!(:tl_updated_yesterday) { described_class.create(id: 1, statuses_updated_at: Time.zone.now - 1.day) }
    let!(:tl_not_updated) { described_class.create(id: 2, statuses_updated_at: nil) }
    let!(:tl_just_updated) { described_class.create(id: 3, statuses_updated_at: Time.zone.now) }

    it 'returns twitter lists whose statuses have not been updated, or were updated before the specified time' do
      expect(sub).to include(tl_updated_yesterday)
      expect(sub).to include(tl_not_updated)
      expect(sub).not_to include(tl_just_updated)
    end
  end
end
