require 'spec_helper'

describe UsersController do
  fixtures :users
  let(:user_params) do
    { contact_name: 'Barack',
      organization_name: 'White House',
      email: 'barack@whitehouse.gov',
      password: 'Michelle2016!' }
  end

  let(:permitted_params) { %i[contact_name organization_name email] }

  describe '#create' do
    it do
      # to avoid depreication warning had to put params there twice
      # https://github.com/thoughtbot/shoulda-matchers/issues/867
      is_expected.to permit(*permitted_params).
        for(:create, params: { params: { user: user_params } })
    end

    context 'when the User#save was successful and User has government affiliated email' do
      let(:user) do
        mock_model(User,
                   has_government_affiliated_email?: true,
                   is_affiliate?: true)
      end

      before do
        expect(User).to receive(:new).and_return(user)
        expect(user).to receive(:save).and_return(true)
        post :create, params: { user: user_params }
      end

      it { is_expected.to assign_to(:user).with(user) }
      it { is_expected.to set_flash.to(/Thank you for signing up/) }
      it { is_expected.to redirect_to(account_url) }
    end

    context 'when the User#save was successful and User does not have government affiliated email' do
      let(:user) do
        mock_model(User,
                   has_government_affiliated_email?: false,
                   is_affiliate?: true)
      end

      before do
        expect(User).to receive(:new).and_return(user)
        expect(user).to receive(:save).and_return(true)
        post :create, params: { user: user_params }
      end

      it { is_expected.to assign_to(:user).with(user) }
      it { is_expected.to set_flash.to(/Sorry! You don't have a \.gov or \.mil email address/) }
      it { is_expected.to redirect_to(account_url) }
    end

    context 'when the User#save failed' do
      let(:user) do
        mock_model(User,
                   has_government_affiliated_email?: true,
                   is_affiliate?: true)
      end

      before do
        expect(User).to receive(:new).and_return(user)
        expect(user).to receive(:save).and_return(false)
        post :create, params: { user: user_params }
      end

      it { is_expected.to assign_to(:user).with(user) }
      it { is_expected.to render_template(:new) }
    end
  end

  describe '#show' do
    context 'when logged in as affiliate' do
      before { activate_authlogic }
      include_context 'approved user logged in'

      before { get :show, params: { id: current_user.id } }

      it { is_expected.to assign_to(:user).with(current_user) }
    end
  end

  describe '#edit' do
    context 'when logged in as affiliate' do
      before { activate_authlogic }
      include_context 'approved user logged in'

      before { get :edit, params: { id: current_user.id } }

      it { is_expected.to assign_to(:user).with(current_user) }
    end
  end

  describe '#update' do
    let(:update_user) do
      post :update,
           params: { id: current_user.id,
                     user: update_params }
    end

    let(:update_params) do
      { 'contact_name': 'BAR', 'email': 'changed@foo.com' }
    end

    context 'when logged in as affiliate' do
      before { activate_authlogic }
      include_context 'approved user logged in'

      it do
      # to avoid depreication warning had to put params there twice
      # https://github.com/thoughtbot/shoulda-matchers/issues/867
      is_expected.to permit(*permitted_params).
        for(:update, params: { params: { user: update_params } })
      end

      context 'when the User#update_attributes was successfully' do
        before do
          expect(current_user).to receive(:update_attributes).
            with(update_params).and_return(true)

          update_user
        end

        it { is_expected.to assign_to(:user).with(current_user) }
        it { is_expected.to redirect_to account_url }
        it { is_expected.to set_flash.to('Account updated!') }
      end

      context 'when the User#update_attributes failed' do
        before do
          expect(current_user).to receive(:update_attributes).with(update_params).
            and_return(false)

          update_user
        end

        it { is_expected.to assign_to(:user).with(current_user) }
        it { is_expected.to render_template(:edit) }
      end
    end
  end

  context "when logged in as a developer" do
    before do
      activate_authlogic
      @user = users('non_affiliate_admin')
      UserSession.create(@user)
    end

    describe 'do GET on show' do
      it 'should redirect the developer to the USA.gov developer page' do
        get :show, params: { id: @user.id }
        expect(response).to redirect_to(developer_redirect_url)
      end
    end

    describe 'do GET on edit' do
      it 'should redirect the developer to the USA.gov developer page' do
        get :edit, params: { id: @user.id }
        expect(response).to redirect_to(developer_redirect_url)
      end
    end

    describe 'do POST on update' do
      it 'should redirect the developer to the USA.gov developer page' do
        post :update, params: { id: @user.id, user: {email: 'changed@foo.com'} }
        expect(response).to redirect_to(developer_redirect_url)
      end
    end
  end
end
