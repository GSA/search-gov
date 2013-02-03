require 'spec_helper'

describe PasswordResetsController do
  context "when unknown token is passed in" do
    it "should redirect to the home page" do
      get :edit, :id=>"fail"
      response.should redirect_to(home_page_path)
    end
  end

  describe '#create' do
    context 'when params[:email] is not a string' do
      before { post :create, email: { 'foo' => 'bar' } }
      it { should set_the_flash.to(/No user was found with that email address/).now }
    end
  end
end
