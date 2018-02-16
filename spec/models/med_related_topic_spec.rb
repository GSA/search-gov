require 'spec_helper'

describe MedRelatedTopic do
  it { is_expected.to validate_presence_of(:related_medline_tid) }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to belong_to(:med_topic) }
end

