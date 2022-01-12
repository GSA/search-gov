require 'spec_helper'

describe 'admin/search_module_ctrs/show.html.haml' do
  fixtures :users
  let(:module1) { SearchModuleCtrStat.new('Module 1', 'MOD1', ImpressionClickStat.new(456, 123), ImpressionClickStat.new(45, 12)) }
  let(:module2) { SearchModuleCtrStat.new('Module 2', 'MOD2', ImpressionClickStat.new(1000, 500), ImpressionClickStat.new(105, 17)) }
  let(:module3) { SearchModuleCtrStat.new('Module 3', 'MOD3', ImpressionClickStat.new(123, 10), ImpressionClickStat.new(0, 12)) }
  let(:search_module_ctrs) { [module2, module1, module3] }

  before do
    activate_authlogic
    admin_user = users(:affiliate_admin)
    UserSession.create(admin_user)
    allow(view).to receive(:current_user).and_return admin_user
    assign :search_module_ctrs, search_module_ctrs
  end

  it 'shows the stats' do
    render
    expect(rendered).to have_content('Search Module CTRs',
                                     normalize_ws: true)
    expect(rendered).to have_content('Module 2 (MOD2) (drill down) 1,000 500 50.0% 105 17 16.2%',
                                     normalize_ws: true)
    expect(rendered).to have_content('Module 1 (MOD1) (drill down) 456 123 27.0% 45 12 26.7%',
                                     normalize_ws: true)
    expect(rendered).to have_content('Module 3 (MOD3) (drill down) 123 10 8.1% 0 12',
                                     normalize_ws: true)
    expect(rendered).to have_content('All Modules 1,579 633 40.1% 150 41 27.3%',
                                     normalize_ws: true)
  end

end
