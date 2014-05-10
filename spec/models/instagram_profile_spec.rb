require 'spec_helper'

describe InstagramProfile do
  fixtures :instagram_profiles

  it { should validate_presence_of :id }
  it { should validate_presence_of :username }
  it { should validate_uniqueness_of :id }
end
