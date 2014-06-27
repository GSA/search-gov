require 'spec_helper'

describe Admin::FederalRegisterAgenciesController do
  fixtures :users, :affiliates, :memberships

  describe '#reimport' do
    before do
      activate_authlogic
      UserSession.create({ email: users('affiliate_admin').email, password: 'admin' })
    end

    it 'imports Federal Register agencies' do
      FederalRegisterAgencyData.should_receive(:import)
      get :reimport
    end
  end
end
