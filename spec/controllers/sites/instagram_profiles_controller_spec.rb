require 'spec_helper'

describe Sites::InstagramProfilesController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index, site_id: 100
  end

  describe '#destroy' do
    it_should_behave_like 'restricted to approved user', :delete, :destroy, site_id: 100, id: 100
  end
end
