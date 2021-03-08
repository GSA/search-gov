require 'spec_helper'

describe TwitterProfile do
  fixtures :affiliates

  before do
    @valid_attributes = {
      twitter_id: 123,
      screen_name: 'USASearch',
      name: 'USASearch',
      profile_image_url: 'http://a0.twimg.com/profile_images/1879738641/USASearch_avatar_normal.png'
    }
  end

  it { is_expected.to have_many :tweets }
  it { is_expected.to have_many :affiliates }
  it { is_expected.to have_many(:affiliate_twitter_settings).dependent(:destroy) }
  it { is_expected.to have_and_belong_to_many :twitter_lists }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :screen_name }
  it { is_expected.to validate_presence_of :twitter_id }
  it { is_expected.to validate_presence_of :profile_image_url }

  context 'when screen_name has leading @' do
    it 'should normalize screen_name before validation' do
      tp = described_class.create!(@valid_attributes.merge(screen_name: '@at_sign'))
      expect(tp.screen_name).to eq('at_sign')
    end
  end

  context 'when screen_name has trailing spaces' do
    it 'should normalize screen_name before validation' do
      tp = described_class.create!(@valid_attributes.merge(screen_name: 'CDCSalud  '))
      expect(tp.screen_name).to eq('CDCSalud')
    end
  end

  it 'should create an instance with valid attributes' do
    described_class.create!(@valid_attributes)

    is_expected.to validate_uniqueness_of(:twitter_id)
  end

  describe '#link_to_profile' do
    before do
      @profile = described_class.create!(@valid_attributes)
    end

    it 'should output a properly formatted link to the tweet' do
      expect(@profile.link_to_profile).to eq('https://twitter.com/USASearch')
    end
  end

  describe '.active_twitter_ids' do
    let(:affiliate1) { affiliates(:usagov_affiliate) }
    let(:affiliate2) { affiliates(:gobiernousa_affiliate) }

    before do
      profile = described_class.new(twitter_id: 100, name: 'usasearch', profile_image_url: 'http://twitter.com/profile100.jpg')
      profile.save(validate: false)
      affiliate1.twitter_profiles << profile
      profile = described_class.new(twitter_id: 101, name: 'usasearchdev', profile_image_url: 'http://twitter.com/profile101.jpg')
      profile.save(validate: false)
      affiliate1.twitter_profiles << profile
      affiliate2.twitter_profiles << profile

      profile = described_class.new(twitter_id: 102, name: 'usagov', profile_image_url: 'http://twitter.com/profile102.jpg')
      profile.save(validate: false)
    end

    it 'should return twitter_ids that for profiles that belongs to an affiliate' do
      expect(described_class.active_twitter_ids).to eq([100, 101])
    end
  end

  describe '.show_lists_enabled' do
    let(:affiliate1) { affiliates(:usagov_affiliate) }
    let(:affiliate2) { affiliates(:gobiernousa_affiliate) }

    before do
      profile = described_class.new(twitter_id: 100, name: 'usasearch', profile_image_url: 'http://twitter.com/profile100.jpg')
      profile.save(validate: false)
      affiliate1.twitter_profiles << profile
      affiliate1.affiliate_twitter_settings.find_by_twitter_profile_id(profile.id).update_attributes!(show_lists: 1)

      profile = described_class.new(twitter_id: 101, name: 'usasearchdev', profile_image_url: 'http://twitter.com/profile101.jpg')
      profile.save(validate: false)
      affiliate1.twitter_profiles << profile
      affiliate1.affiliate_twitter_settings.find_by_twitter_profile_id(profile.id).update_attributes!(show_lists: 1)
      affiliate2.twitter_profiles << profile
      affiliate2.affiliate_twitter_settings.find_by_twitter_profile_id(profile.id).update_attributes!(show_lists: 1)

      profile = described_class.new(twitter_id: 102, name: 'usagov', profile_image_url: 'http://twitter.com/profile102.jpg')
      profile.save(validate: false)
      affiliate2.twitter_profiles << profile
    end

    it 'should return affiliate profiles with show lists enabled' do
      profiles_with_show_lists_enabled = described_class.show_lists_enabled
      expect(profiles_with_show_lists_enabled).to eq([described_class.find_by_twitter_id(100), described_class.find_by_twitter_id(101)])
    end
  end
end
