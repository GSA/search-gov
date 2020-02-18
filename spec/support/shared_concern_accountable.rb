shared_examples 'require complete account' do |request_method, action, parameters = nil|

  context 'when user did not supply contact_name' do
    let(:current_user) { users(:no_contact_name) }

    before do
      UserSession.create current_user
      expect(User).to receive(:find_by_id).and_return(current_user)
      send request_method, action, params: parameters
    end

    it 'redirects to account edit page' do
      expect(response).to redirect_to('/account/edit')
    end

    context 'when the user has no contact_name' do
      let(:current_user) { users(:no_contact_name) }

      it 'returns error for user to supply contact name' do
        expect(current_user.errors.messages[:contact_name].first).
          to eq('You must supply a contact name')
      end
    end

    context 'when the user has no organization_name' do
      let(:current_user) { users(:no_organization_name) }

      it 'returns error for user to supply organization name' do
        expect(current_user.errors.messages[:organization_name].first).
          to eq('You must supply an organization name')
      end
    end
  end
end