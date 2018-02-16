require 'spec_helper'

describe MedSite do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to belong_to(:med_topic) }
end
