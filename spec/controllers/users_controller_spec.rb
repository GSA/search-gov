require 'spec_helper'

describe UsersController do
  fixtures :users

  describe '#create' do
    context 'when the User#save was successful and User has government affiliated email' do
      let(:user) do
        mock_model(User,
                   has_government_affiliated_email?: true,
                   is_affiliate?: true)
      end

      before do
        User.should_receive(:new).and_return(user)
        user.should_receive(:save).and_return(true)
        post :create
      end

      it { should assign_to(:user).with(user) }
      it { should set_the_flash.to(/Thank you for signing up/) }
      it { should redirect_to(account_url) }
    end

    context 'when the User#save was successful and User does not have government affiliated email' do
      let(:user) do
        mock_model(User,
                   has_government_affiliated_email?: false,
                   is_affiliate?: true)
      end

      before do
        User.should_receive(:new).and_return(user)
        user.should_receive(:save).and_return(true)
        post :create
      end

      it { should assign_to(:user).with(user) }
      it { should set_the_flash.to(/Sorry! You don't have a \.gov or \.mil email address/) }
      it { should redirect_to(account_url) }
    end

    context 'when the User#save failed' do
      let(:user) do
        mock_model(User,
                   has_government_affiliated_email?: true,
                   is_affiliate?: true)
      end

      before do
        User.should_receive(:new).and_return(user)
        user.should_receive(:save).and_return(false)
        post :create
      end

      it { should assign_to(:user).with(user) }
      it { should render_template(:new) }
    end
  end

  describe '#show' do
    context 'when logged in as affiliate' do
      before { activate_authlogic }
      include_context 'approved user logged in'

      before { get :show, id: current_user.id }

      it { should assign_to(:user).with(current_user) }
    end
  end

  describe '#edit' do
    context 'when logged in as affiliate' do
      before { activate_authlogic }
      include_context 'approved user logged in'

      before { get :edit, id: current_user.id }

      it { should assign_to(:user).with(current_user) }
    end
  end

  describe '#update' do
    context 'when logged in as affiliate' do
      before { activate_authlogic }
      include_context 'approved user logged in'

      context 'when the User#update_attributes was successfully' do
        before do
          current_user.should_receive(:update_attributes).
            with('contact_name' => 'BAR', 'email' => 'changed@foo.com').
            and_return(true)

          post :update,
               id: current_user.id,
               user: { contact_name: 'BAR', email: 'changed@foo.com' }
        end

        it { should assign_to(:user).with(current_user) }
        it { should redirect_to account_url }
        it { should set_the_flash.to('Account updated!') }
      end

      context 'when the User#update_attributes failed' do
        before do
          current_user.should_receive(:update_attributes).
            with('contact_name' => 'BAR', 'email' => 'changed@foo.com').
            and_return(false)

          post :update,
               id: current_user.id,
               user: { contact_name: 'BAR', email: 'changed@foo.com' }
        end

        it { should assign_to(:user).with(current_user) }
        it { should render_template(:edit) }
      end
    end
  end

  context "when logged in as a developer" do
    before do
      activate_authlogic
      @user = users('non_affiliate_admin')
      UserSession.create(:email=> @user.email, :password => "admin")
    end

    describe "do GET on show" do
      it "should redirect the developer to the USA.gov developer page" do
        get :show, :id => @user.id
        response.should redirect_to(developer_redirect_url)
      end
    end

    describe "do GET on edit" do
      it "should redirect the developer to the USA.gov developer page" do
        get :edit, :id => @user.id
        response.should redirect_to(developer_redirect_url)
      end
    end

    describe "do POST on update" do
      it "should redirect the developer to the USA.gov developer page" do
        post :update, :id => @user.id, :user => {:email => "changed@foo.com"}
        response.should redirect_to(developer_redirect_url)
      end
    end
  end
end
