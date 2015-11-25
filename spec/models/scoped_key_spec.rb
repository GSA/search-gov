require 'spec_helper'

describe ScopedKey do
  it { should belong_to(:affiliate) }
  it { should validate_presence_of :key }
end
