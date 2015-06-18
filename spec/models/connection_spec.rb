require 'spec_helper'

describe Connection do
  fixtures :users, :affiliates, :memberships
  let(:affiliate) { affiliates(:gobiernousa_affiliate) }
  let(:connection) { affiliate.connections.create!(:affiliate_name => '   usagov   ', :label => 'Search in English') }

  it { should validate_presence_of :connected_affiliate_id }
  it { should validate_presence_of :label }

  describe '#affiliate_name' do

    it 'should return the connected affiliate name' do
      Connection.find(connection.id).affiliate_name.should == 'usagov'
    end
  end

  describe '#affiliate_name=' do
    let(:basic_affiliate) { affiliates(:basic_affiliate) }

    it 'should set connected site' do
      connection.affiliate_name = nil
      connection.connected_affiliate.should be_nil
      connection.affiliate_name = 'invalidname'
      connection.connected_affiliate.should be_nil
      connection.affiliate_name = basic_affiliate.name
      connection.connected_affiliate.should == basic_affiliate
    end

    it 'should not allow connected site to also be the connection owner' do
      connection.affiliate_name = 'gobiernousa'
      connection.should_not be_valid
    end

    it 'should require connected affiliate to exist' do
      connection.affiliate_name = 'unknown'
      connection.should_not be_valid
    end
  end

  describe '#dup' do
    subject(:original_instance) { connection }

    include_examples 'site dupable'
  end
end
