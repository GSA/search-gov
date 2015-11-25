require 'spec_helper'

describe "sites/routed_query_queries/show.html.haml" do
  fixtures :affiliates, :users, :routed_queries, :scoped_keys
  let(:site) { affiliates(:basic_affiliate) }
  let(:routed_query) { routed_queries(:unclaimed_money) }

  before do
    activate_authlogic
    assign :site, site
    affiliate_user = users(:affiliate_manager)
    UserSession.create(affiliate_user)
    view.stub!(:current_user).and_return affiliate_user
    assign :routed_query, routed_query
    view.stub!(:params).and_return({ module_tag: 'QRTD' })
  end

  context 'regardless of the data available' do
    it "shows the header for the current month" do
      render
      rendered.should contain "Routed Query Keywords for Current Month"
      rendered.should contain "Description: Everybody wants it"
    end

    context 'help link is available' do
      before do
        HelpLink.stub(:find_by_request_path).and_return stub_model(HelpLink, request_path: '/sites/routed_query_queries', help_page_url: 'http://www.help.gov/')
      end

      it "shows help link" do
        render
        rendered.should have_selector("a.help-link.menu", href: 'http://www.help.gov/', content: 'Help Manual')
      end
    end
  end

  context 'routed query exists' do
    before do
      render
    end

    it 'should show a Keen pie chart for the current month' do
      rendered.should have_selector("#keen-queries-pie", { "data-module" => "QRTD", "data-model-id" => "#{routed_query.id}", 'data-key' => "#{site.scoped_key.key}" })
    end
  end

end
