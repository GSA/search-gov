require 'spec_helper'

describe TagFilter do
  fixtures :tag_filters, :affiliates
  it { is_expected.to belong_to(:affiliate) }
  it { is_expected.to validate_presence_of :tag }
  it { is_expected.to validate_presence_of :affiliate_id }
  it { is_expected.to validate_uniqueness_of(:tag).scoped_to(:affiliate_id).case_insensitive }
end
