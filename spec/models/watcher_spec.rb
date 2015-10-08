require 'spec_helper'

describe Watcher do
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of(:name).case_insensitive }
end
