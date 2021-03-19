require 'spec_helper'

describe Connection do
  fixtures :users, :affiliates, :memberships
  let(:affiliate) { affiliates(:gobiernousa_affiliate) }
  let(:connection) { affiliate.connections.create!(affiliate_name: '   usagov   ', label: 'Search in English') }

  it { is_expected.to validate_presence_of :connected_affiliate_id }
  it { is_expected.to validate_presence_of :label }

  describe '#affiliate_name' do

    it 'should return the connected affiliate name' do
      expect(described_class.find(connection.id).affiliate_name).to eq('usagov')
    end
  end

  describe '#affiliate_name=' do
    let(:basic_affiliate) { affiliates(:basic_affiliate) }

    it 'should set connected site' do
      connection.affiliate_name = nil
      expect(connection.connected_affiliate).to be_nil
      connection.affiliate_name = 'invalidname'
      expect(connection.connected_affiliate).to be_nil
      connection.affiliate_name = basic_affiliate.name
      expect(connection.connected_affiliate).to eq(basic_affiliate)
    end

    it 'should not allow connected site to also be the connection owner' do
      connection.affiliate_name = 'gobiernousa'
      expect(connection).not_to be_valid
    end

    it 'should require connected affiliate to exist' do
      connection.affiliate_name = 'unknown'
      expect(connection).not_to be_valid
    end
  end

  describe '#dup' do
    subject(:original_instance) { connection }

    include_examples 'site dupable'
  end
end
