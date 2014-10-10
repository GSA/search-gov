require 'spec_helper'

describe OutboundRateLimit do
  it { should validate_presence_of :limit }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).case_insensitive }
end
