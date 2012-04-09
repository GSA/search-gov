require 'spec/spec_helper'

describe Connection do
  fixtures :users, :affiliates

  it { should validate_presence_of :connected_affiliate_id }
  it { should validate_presence_of :label }
end
