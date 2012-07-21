require 'spec/spec_helper'

describe MedRelatedTopic do
  it { should validate_presence_of(:related_medline_tid) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:url) }
  it { should belong_to(:med_topic) }
end

