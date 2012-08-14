require 'spec_helper'

describe MedSite do
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:url) }
  it { should belong_to(:med_topic) }
end
