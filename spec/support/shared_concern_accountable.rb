shared_examples 'require complete account' do |request_method, action, parameters = nil|

  context 'when user did not supply contact info' do
    let(:current_user) { users(:no_first_name) }

    before do
      UserSession.create current_user
      expect(User).to receive(:find_by_id).and_return(current_user)
      send request_method, action, params: parameters
    end

    it 'redirects to account edit page' do
      expect(response).to redirect_to('/account/edit')
    end

    context 'when the user has no first_name' do
      it 'returns error for user to supply contact name' do
        expect(current_user.errors.messages[:first_name].first).
          to eq('You must supply a first name')
      end
    end

    context 'when the user has no last_name' do
      let(:current_user) { users(:no_last_name) }

      it 'returns error for user to supply contact name' do
        expect(current_user.errors.messages[:last_name].first).
          to eq('You must supply a last name')
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
