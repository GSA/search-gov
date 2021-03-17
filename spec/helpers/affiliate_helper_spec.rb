require 'spec_helper'

describe AffiliateHelper do
  describe '#render_managed_header' do
    context 'when the affiliate has a header image and an exception occurs when trying to retrieve the image' do
      let(:header_image) { double('header image') }
      let(:affiliate) { mock_model(Affiliate,
                                   css_property_hash: Affiliate::DEFAULT_CSS_PROPERTIES,
                                   header_image_file_name: 'logo.gif',
                                   header_image: header_image) }

      before do
        expect(header_image).to receive(:url).and_raise
      end

      specify { expect(helper.render_managed_header(affiliate)).not_to have_select(:img) }
    end
  end

  describe '#render_affiliate_body_style' do
    context 'when an error occurs' do
      let(:affiliate) { mock_model(Affiliate, css_property_hash: {}, page_background_image_file_name: 'bg.png') }
      it 'should return only background-color' do
        expect(helper).to receive(:render_affiliate_css_property_value).with({}, :page_background_color).and_return('#DDDDDD')
        expect(affiliate).to receive(:page_background_image).and_raise(StandardError)
        expect(helper.render_affiliate_body_style(affiliate)).to eq('background-color: #DDDDDD')
      end
    end

    context 'when the affiliate has a background image configured' do
      let(:affiliate) do
        mock_model(Affiliate, {
          page_background_image_file_name: 'background.png',
          page_background_image: double('background_image', url: 'some_background_url'),
          css_property_hash: { page_background_image_repeat: 'some_background_repeat' }
        })
      end

      it 'includes the background image as background image style' do
        expected_style = 'background: #DFDFDF url(some_background_url) some_background_repeat center top'
        expect(helper.render_affiliate_body_style(affiliate)).to eq(expected_style)
      end
    end
  end

  describe '#available_templates' do
    context 'when no templates have been made available' do
      let(:affiliate) { mock_model(Affiliate, available_templates: []) }

      it 'returns the default template' do
        expect(available_templates(affiliate).first.name).to eq 'Classic'
      end
    end

    context 'when a template has been made available' do
      let(:affiliate) do
        mock_model(Affiliate,
                   available_templates: [double(Template, name: 'temp1'),
                                         double(Template, name: 'temp2')]
                  )
      end

      it 'returns the available templates' do
        expect(available_templates(affiliate).map(&:name)).
          to match_array(['temp1','temp2'])
      end
    end
  end

  describe '#unavailable_templates' do
    context 'when no templates have been made available' do
      let(:affiliate) { mock_model(Affiliate, available_templates: []) }

      it 'returns all templates except the default' do
        expect(unavailable_templates(affiliate).map(&:name)).
          to match_array ['IRS', 'Rounded Header Links', 'Square Header Links']
      end
    end

    describe 'when templates have been made available' do
      let(:affiliate) do
        mock_model(Affiliate,
                   available_templates: [Template.find_by_name('IRS')]
                  )
      end

      it 'returns the unavailable templates' do
        expect(unavailable_templates(affiliate).map(&:name)).
          to match_array ['Classic', 'Rounded Header Links', 'Square Header Links']
      end
    end
  end
end
