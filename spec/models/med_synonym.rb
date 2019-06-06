require 'spec_helper'

describe MedSynonym do
  it { is_expected.to belong_to(:topic).inverse_of(:synonyms) }
  it { is_expected.to validate_presence_of(:medline_title) }
  it { is_expected.to validate_presence_of(:topic) }
end
