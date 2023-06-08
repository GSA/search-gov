require 'spec_helper'

describe MobileHelper do
  describe '#font_stylesheet_link_tag' do
    context 'font_family is blank' do
      it 'returns default css font family' do
        affiliate = mock_model(Affiliate, css_property_hash: {})
        expect(helper.font_stylesheet_link_tag(affiliate)).to include(MobileHelper::DEFAULT_FONT_STYLESHEET_LINK)
      end
    end
  end

  describe '#mobile_header' do
    context 'when unable to retrieve mobile logo URL' do
      it 'renders the site display name' do
        mobile_logo = double('mobile logo')
        expect(mobile_logo).to receive(:url).and_raise
        affiliate = mock_model(Affiliate,
                               display_name: 'USASearch',
                               mobile_logo: mobile_logo,
                               mobile_logo_file_name: 'logo.png',
                               website: nil)

        expect(helper.mobile_header(affiliate)).to have_selector('h1', text: 'USASearch')
      end
    end
  end

  describe '#header_tagline_logo' do
    context 'when unable to retrieve header tagline logo URL' do
      it 'renders the a non-clickable header tagline logo' do
        header_tagline_logo = double('header tagline logo')
        expect(header_tagline_logo).to receive(:url).and_raise
        affiliate = mock_model(Affiliate,
                               display_name: 'USASearch',
                               header_tagline: 'NISH',
                               header_tagline_logo: header_tagline_logo,
                               header_tagline_logo_file_name: 'header_tagline_logo.png',
                               header_tagline_url: nil)
        expect(helper.header_tagline_logo(affiliate)).to be_nil
      end
    end
  end

  describe '#search_results_by_text' do
    context 'when module_tag is AWEB or AIMAG' do
      %w(AWEB AIMAG).each do |module_tag|
        it 'returns Powered by Bing' do
          expect(helper.search_results_by_text(module_tag)).to have_content('Powered by Bing')
        end
      end
    end
  end

  describe '#serp_attribution' do
    context 'when module_tag is AWEB' do
      it 'returns Powered by Bing' do
        expect(helper.serp_attribution('AWEB')).to have_content('Powered by Bing')
      end
    end
  end

  describe '#related_sites_dropdown_label' do
    context 'when label is present' do
      specify { expect(helper.related_sites_dropdown_label('foo')).to eq('foo') }
    end

    context 'when label is nil' do
      specify { expect(helper.related_sites_dropdown_label(nil)).to eq(I18n.t(:'searches.related_sites')) }
    end
  end

  describe '#html_class_hash' do
    fixtures :languages

    context 'when locale is written right-to-left' do
      let(:language) { languages(:ar) }

      it 'should set the HTML direction to rtl' do
        expect(helper.html_class_hash(language)[:dir]).to eq('rtl')
      end
    end
  end
end
