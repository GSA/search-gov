require 'spec_helper'

describe UsersHelper do
  describe '#contact_name' do
    let(:user) { instance_double(User, contact_name: 'Jane', email: 'jane@search.gov') }
    subject(:contact_name) { helper.contact_name(user) }

    it { is_expected.to eq('Jane') }

    context 'when the user does not have a contact name' do
      let(:user) { instance_double(User, contact_name: nil, email: 'jane@search.gov') }

      it { is_expected.to eq('jane@search.gov') }
    end
  end
end
