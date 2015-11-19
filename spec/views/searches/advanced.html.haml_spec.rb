# coding: utf-8
require 'spec_helper'

describe "searches/advanced.html.haml" do
  fixtures :affiliates

  context "visiting the advanced search page for an English language affiliate" do
    let(:affiliate) { affiliates(:usagov_affiliate) }
    before do
      assign(:affiliate, affiliate)
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
                                    href: 'https://msdn.microsoft.com/en-us/library/ff795620.aspx')
    end

    context 'when the search engine is Google' do
      before { affiliate.should_receive(:search_engine).and_return 'Google' }

      it 'should render advanced search operators link' do
        render
        rendered.should have_selector(:a,
                                      content: 'advanced search operators',
                                      href: 'https://support.google.com/websearch/answer/136861?hl=en')
      end
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
    let(:affiliate) { affiliates(:gobiernousa_affiliate) }
    before do
      I18n.locale = :es
      assign(:affiliate, affiliate)
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
                                    href: 'https://msdn.microsoft.com/en-us/library/ff795620.aspx')
    end

    context 'when the search engine is Google' do
      before { affiliate.should_receive(:search_engine).and_return 'Google' }

      it 'should render advanced search operators link' do
        render
        rendered.should have_selector(:a,
                                      content: 'opciones de búsqueda avanzada',
                                      href: 'https://support.google.com/websearch/answer/136861?hl=es')
      end
    end

    after do
      I18n.locale = I18n.default_locale
    end
  end
end
