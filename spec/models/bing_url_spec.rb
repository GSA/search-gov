require 'spec_helper'

describe BingUrl do
  fixtures :bing_urls

  it { should validate_presence_of :normalized_url }
  it { should validate_uniqueness_of :normalized_url }

end