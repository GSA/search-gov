require 'spec_helper'

describe Membership do
  fixtures :affiliates, :users, :memberships

  describe '#dup' do
    subject(:original_instance) { memberships(:four) }

    include_examples 'site dupable'
  end
end
