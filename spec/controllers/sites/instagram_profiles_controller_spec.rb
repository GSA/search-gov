require 'spec_helper'

describe Sites::InstagramProfilesController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create
  end

  describe '#destroy' do
    it_should_behave_like 'restricted to approved user', :delete, :destroy
  end
end
