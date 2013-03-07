require 'spec_helper'

describe BingUrl do
  fixtures :bing_urls

  it { should validate_presence_of :normalized_url }
  it { should validate_uniqueness_of(:normalized_url).case_insensitive }
  it { should have_readonly_attribute :normalized_url }
end