require 'spec_helper'

describe InstagramProfile do
  fixtures :instagram_profiles

  it { is_expected.to validate_presence_of :id }
  it { is_expected.to validate_presence_of :username }
  it { is_expected.to validate_uniqueness_of :id }

  it 'should not notify Oasis after create' do
    expect(Oasis).not_to receive(:subscribe_to_instagram).with(1234, "deptofdefense")
    InstagramProfile.create(id: 1234, username: "deptofdefense")
  end

end
