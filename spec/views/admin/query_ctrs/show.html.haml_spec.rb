require 'spec_helper'

describe "admin/query_ctrs/show.html.haml" do
  fixtures :users, :affiliates, :search_modules
  let(:query_ctr1) { QueryCtrStat.new("query 1", ImpressionClickStat.new(456, 123), ImpressionClickStat.new(45, 12)) }
  let(:query_ctr2) { QueryCtrStat.new("query 2", ImpressionClickStat.new(1000, 500), ImpressionClickStat.new(105, 17)) }
  let(:query_ctr3) { QueryCtrStat.new("query 3", ImpressionClickStat.new(123, 10), ImpressionClickStat.new(0, 12)) }
  let(:query_ctrs) { [query_ctr2, query_ctr1, query_ctr3] }

  before do
    activate_authlogic
    admin_user = users(:affiliate_admin)
    UserSession.create(admin_user)
    allow(view).to receive(:current_user).and_return admin_user
    allow(view).to receive(:params).and_return({ module_tag: 'BOOS', site_id: affiliates(:usagov_affiliate).id })
    assign :query_ctrs, query_ctrs
    assign :search_module, search_modules(:boos)
    assign :site, affiliates(:usagov_affiliate)
  end

  it 'shows the query CTR stats for some search module on some site' do
    render
    expect(rendered).to have_content "Query CTRs for Best Bets Text (BOOS) on USA.gov"
    expect(rendered).to have_content "query 2 1,000 500 50.0% 105 17 16.2%"
    expect(rendered).to have_content "query 1 456 123 27.0% 45 12 26.7%"
    expect(rendered).to have_content "query 3 123 10 8.1% 0 12"
    expect(rendered).to have_content "All Queries 1,579 633 40.1% 150 41 27.3%"
  end

end
