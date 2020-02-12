require 'spec_helper'

shared_examples 'incomplete account' do

  context 'when user did not supply contact_name' do
    fixtures :users
    let(:current_user) { users(:affiliate_admin) }

    before do
      activate_authlogic
      UserSession.create current_user
      expect(User).to receive(:find_by_id).and_return(current_user)
      get :index
    end

    let(:current_user) { users(:no_contact_name) }

    it 'redirects to account edit page' do
      expect(response).to redirect_to('/account/edit')
    end

    it 'returns error for user to supply contact name' do
      expect(current_user.errors.messages[:contact_name].first).
        to eq('You must supply a contact name')
    end
  end
end