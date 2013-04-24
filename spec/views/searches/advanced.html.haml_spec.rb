# coding: utf-8
require 'spec_helper'

describe "searches/advanced.html.haml" do
  fixtures :affiliates

  context "visiting the advanced search page for an English language affiliate" do
    before do
      assign(:affiliate, affiliates(:usagov_affiliate))
    end

    it "should display text via the I18n in English" do
      render
      rendered.should contain(/Use the options on this page to create a very specific search./)
    end

    it "should include a hidden input tag with the affiliate" do
      render
      rendered.should have_selector("input[type='hidden'][name='affiliate'][value='usagov']")
    end

    it "should include a hidden input tag with the scope id if a scope id is passed" do
      assign(:affiliate, affiliates(:power_affiliate))
      assign(:scope_id, 'SomeScope')
      render
      rendered.should have_selector("input[type='hidden'][name='scope_id'][value='SomeScope']")
    end

    it 'should render advanced search operators link' do
      render
      rendered.should have_selector(:a,
                                    content: 'advanced search operators',
                                    href: 'http://onlinehelp.microsoft.com/en-us/bing/ff808421.aspx')
    end

    describe "adult filter options" do
      context "when no options are present" do
        it "should default to moderate for adult searches" do
          render
          rendered.should have_selector("input[type='radio'][name='filter'][value='1'][checked='checked']")
        end
      end

      context "when a valid option is present" do
        before do
          params['filter'] = '2'
        end

        it "should mark that option as selected" do
          render
          rendered.should have_selector("input[type='radio'][name='filter'][value='2'][checked='checked']")
        end
      end
    end
  end

  context "visiting the Spanish version of the page" do
    before do
      I18n.locale = :es
      assign(:affiliate, affiliates(:gobiernousa_affiliate))
    end

    it "should display text in Spanish" do
      render
      rendered.should contain(/Use las siguientes opciones para hacer una búsqueda específica\./)
    end

    it "should show options for adult searches, defaulting to moderate" do
      render
      rendered.should have_selector("input[type='radio'][name='filter'][value='1'][checked='checked']")
    end

    it 'should render advanced search operators link' do
      render
      rendered.should have_selector(:a,
                                    content: 'opciones de búsqueda avanzada',
                                    href: 'http://onlinehelp.microsoft.com/en-us/bing/ff808421.aspx')
    end

    after do
      I18n.locale = I18n.default_locale
    end
  end
end
