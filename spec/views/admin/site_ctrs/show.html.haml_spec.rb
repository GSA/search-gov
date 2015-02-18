require 'spec_helper'

describe "admin/site_ctrs/show.html.haml" do
  fixtures :users, :affiliates, :search_modules
  let(:aff1) { affiliates(:usagov_affiliate) }
  let(:aff2) { affiliates(:basic_affiliate) }
  let(:aff3) { affiliates(:power_affiliate) }
  let(:site_ctr1) { SiteCtrStat.new(aff1, ImpressionClickStat.new(456, 123), ImpressionClickStat.new(45, 12)) }
  let(:site_ctr2) { SiteCtrStat.new(aff2, ImpressionClickStat.new(1000, 500), ImpressionClickStat.new(105, 17)) }
  let(:site_ctr3) { SiteCtrStat.new(aff3, ImpressionClickStat.new(123, 10), ImpressionClickStat.new(0, 12)) }
  let(:site_ctrs) { [site_ctr2, site_ctr1, site_ctr3] }

  before do
    activate_authlogic
    admin_user = users(:affiliate_admin)
    UserSession.create(admin_user)
    view.stub!(:current_user).and_return admin_user
    view.stub!(:params).and_return({ module_tag: 'BOOS' })
    assign :site_ctrs, site_ctrs
    assign :search_module, search_modules(:boos)
  end

  it 'shows the site CTR stats for some search module' do
    render
    rendered.should contain "Site CTRs for Best Bets Text (BOOS)"
    rendered.should contain "NPS Site (drill down) 1,000 500 50.0% 105 17 16.2%"
    rendered.should contain "USA.gov (drill down) 456 123 27.0% 45 12 26.7%"
    rendered.should contain "Noaa Site (drill down) 123 10 8.1% 0 12"
    rendered.should contain "All Sites 1,579 633 40.1% 150 41 27.3%"
  end

end