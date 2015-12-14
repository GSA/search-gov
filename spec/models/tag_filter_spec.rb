require 'spec_helper'

describe TagFilter do
  fixtures :tag_filters, :affiliates
  it { should belong_to(:affiliate) }
  it { should validate_presence_of :tag }
  it { should validate_presence_of :affiliate_id }
  it { should validate_uniqueness_of(:tag).scoped_to(:affiliate_id).case_insensitive }
end
