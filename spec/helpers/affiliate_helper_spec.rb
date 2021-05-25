require 'spec_helper'

describe AffiliateHelper do
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
