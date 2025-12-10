require 'spec_helper'

describe 'sites/sites/show' do
  fixtures :affiliates, :users
  let(:site) { affiliates(:basic_affiliate) }

  before do
    activate_authlogic
    assign :site, site
    @affiliate_user = users(:affiliate_manager)
    UserSession.create(@affiliate_user)
    allow(view).to receive(:current_user).and_return @affiliate_user
  end

  context 'when affiliate user views the dashboard' do
    before do
        assign :dashboard, double('RtuDashboard').as_null_object
    end 
        
    it 'should show header' do
      render
      expect(rendered).to have_content %{Customize your search experience}
    end
  end
end
