require 'spec/spec_helper'
describe "layouts/affiliate" do
  before do
    affiliate_template = stub('affiliate template', :stylesheet => 'default')
    affiliate = mock_model(Affiliate,
                           :is_sayt_enabled? => true,
                           :exclude_webtrends? => false,
                           :header => 'header',
                           :footer => 'footer',
                           :affiliate_template => affiliate_template,
                           :favicon_url => 'http://cdn.agency.gov/favicon.ico',
                           :external_css_url => 'http://cdn.agency.gov/custom.css',
                           :css_overrides => { :link_color => '#33ff33', :visited_link_color => '#888888' }.to_json,
                           :uses_one_serp? => true)
    assign(:affiliate, affiliate)
    view.should_receive(:render_affiliate_css_overrides).and_return('affiliate_css_overrides')
  end

  it "should render css overrides template" do
    render
    rendered.should have_content("affiliate_css_overrides")
  end

  context "when page is displayed" do
    it "should should show webtrends javascript" do
      render
      rendered.should have_selector("script[src='/javascripts/webtrends_affiliates.js'][type='text/javascript']")
    end
  end

  context "when exclude_webtrends flag is set to true" do
    before do
      affiliate_template = stub('affiliate template', :stylesheet => 'default')
      affiliate = mock_model(Affiliate,
                             :is_sayt_enabled? => true,
                             :exclude_webtrends? => true,
                             :header => 'header',
                             :footer => 'footer',
                             :affiliate_template => affiliate_template,
                             :favicon_url => 'http://cdn.agency.gov/favicon.ico',
                             :external_css_url => 'http://cdn.agency.gov/custom.css',
                             :css_overrides => { :link_color => '#33ff33', :visited_link_color => '#888888' }.to_json,
                             :uses_one_serp? => true)
      assign(:affiliate, affiliate)
    end

    it "should not show webtrends javascript" do
      render
      rendered.should_not have_selector("script[src='/javascripts/webtrends_affiliates.js'][type='text/javascript']")
    end
  end
end