require 'spec_helper'

describe InstagramProfile do
  fixtures :instagram_profiles

  it { should validate_presence_of :id }
  it { should validate_presence_of :username }
  it { should validate_uniqueness_of :id }

  it 'should notify Oasis after create' do
    Oasis.should_receive(:subscribe_to_instagram).with(1234, "deptofdefense")
    InstagramProfile.create(id: 1234, username: "deptofdefense")
  end

end
