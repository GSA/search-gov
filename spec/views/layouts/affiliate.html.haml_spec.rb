# coding: utf-8
require 'spec_helper'

describe "layouts/affiliate" do
  before do
    affiliate = mock_model(Affiliate,
                           :is_sayt_enabled? => true,
                           :nested_header_footer_css => nil,
                           :header => 'header',
                           :footer => 'footer',
                           :favicon_url => 'http://cdn.agency.gov/favicon.ico',
                           :external_css_url => 'http://cdn.agency.gov/custom.css',
                           :css_property_hash => {},
                           :page_background_image_file_name => nil,
                           :uses_managed_header_footer? => false,
                           :managed_header_css_properties => nil,
                           :show_content_border? => true,
                           :show_content_box_shadow? => true,
                           :connections => [],
                           :locale => 'en',
                           :jobs_enabled? => false,
                           :ga_web_property_id => nil,
                           :external_tracking_code => nil)
    assign(:affiliate, affiliate)
    search = mock(WebSearch, :query => 'america')
    assign(:search, search)
  end

  context 'when SAYT is not enabled and @search is a News Search' do
    before do
      affiliate = mock_model(Affiliate,
                             :is_sayt_enabled? => false,
                             :nested_header_footer_css => nil,
                             :header => 'header',
                             :footer => 'footer',
                             :favicon_url => 'http://cdn.agency.gov/favicon.ico',
                             :external_css_url => 'http://cdn.agency.gov/custom.css',
                             :css_property_hash => { },
                             :page_background_image_file_name => nil,
                             :uses_managed_header_footer? => false,
                             :managed_header_css_properties => nil,
                             :show_content_border? => true,
                             :show_content_box_shadow? => true,
                             :jobs_enabled? => false,
                             :connections => [],
                             :locale => 'en',
                             :ga_web_property_id => nil,
                             :external_tracking_code => nil)
      assign(:affiliate, affiliate)
      search = mock(NewsSearch, query: 'america')
      search.should_receive(:is_a?).with(NewsSearch).and_return(true)
      assign(:search, search)
    end

    it 'should include jquery-ui library' do
      render
      rendered.should have_selector("link[href^='/stylesheets/jquery-ui/jquery-ui.custom.css'][type='text/css']")
      rendered.should have_selector("script[src^='/javascripts/jquery/jquery-ui.custom.min.js'][type='text/javascript']")
    end
  end

  context 'when the en site has a footer' do
    it 'should render Show footer tooltip' do
      render
      rendered.should have_selector(:a, title: 'Show footer')
      rendered.should have_content('Hide footer')
    end
  end

  context 'when the affiliate is not jobs govbox enabled' do
    it 'should not prompt user to use location' do
      render
      rendered.should_not contain(/getGeoLocation/)
    end
  end

  context 'when the affiliate is jobs govbox enabled' do
    before do
      affiliate = mock_model(Affiliate,
                             :is_sayt_enabled? => true,
                             :nested_header_footer_css => nil,
                             :header => 'header',
                             :footer => 'footer',
                             :favicon_url => 'http://cdn.agency.gov/favicon.ico',
                             :external_css_url => 'http://cdn.agency.gov/custom.css',
                             :css_property_hash => {},
                             :page_background_image_file_name => nil,
                             :uses_managed_header_footer? => false,
                             :managed_header_css_properties => nil,
                             :show_content_border? => true,
                             :show_content_box_shadow? => true,
                             :connections => [],
                             :locale => 'en',
                             :jobs_enabled? => true,
                             :ga_web_property_id => nil,
                             :external_tracking_code => nil)
      assign(:affiliate, affiliate)
      search = mock(WebSearch, :query => 'america')
      assign(:search, search)
    end

    it 'should prompt user to use location' do
      render
      rendered.should contain(/getGeoLocation/)
    end
  end

  context 'when the es site has a footer' do
    before { I18n.locale = :es }
    after { I18n.locale = I18n.default_locale }

    it 'should render Mostrar pie de página tooltip' do
      render
      rendered.should have_selector(:a, title: 'Mostrar pie de página')
      rendered.should have_content('Esconder pie de página')
    end
  end
end