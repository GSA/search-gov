require 'spec_helper'

describe "sites/best_bet_queries/show.html.haml" do
  fixtures :affiliates, :users, :boosted_contents
  let(:site) { affiliates(:basic_affiliate) }
  let(:best_bet) { boosted_contents(:basic) }

  before do
    activate_authlogic
    assign :site, site
    affiliate_user = users(:affiliate_manager)
    UserSession.create(affiliate_user)
    view.stub!(:current_user).and_return affiliate_user
    assign :best_bet, best_bet
    view.stub!(:params).and_return({ module_tag: 'BOOS' })
  end

  context 'regardless of the data available' do
    it "should show the header for the current month" do
      render
      rendered.should contain "Best Bet Queries for Current Month"
      rendered.should contain "Title: my boosted content"
    end

    context 'when help link is available' do
      before do
        HelpLink.stub(:find_by_request_path).and_return stub_model(HelpLink, request_path: '/sites/best_bet_queries', help_page_url: 'http://www.help.gov/')
      end

      it "should show help link" do
        render
        rendered.should have_selector("a.help-link.menu", href: 'http://www.help.gov/', content: 'Help Manual')
      end
    end
  end

  context 'when best bet exists' do
    before do
      render
    end

    it 'should show a Keen pie chart for the current month' do
      rendered.should have_selector("#keen-queries-pie", { "data-module" => "BOOS", "data-model-id" => "#{best_bet.id}", 'data-key' => "#{site.keen_scoped_key}" })
    end
  end

end
