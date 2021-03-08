require 'spec_helper'

describe ImageSearchLabel do
  let(:en_affiliate) { Affiliate.create!(display_name: 'en Affiliate', name: 'en-site')}
  let(:es_affiliate) { Affiliate.create!(display_name: 'es Affiliate', locale: 'es', name: 'es-site')}

  it { is_expected.to validate_presence_of :affiliate_id }

  describe '#create' do
    it 'should not allow blank name' do
      expect(en_affiliate.image_search_label.name).to eq('Images')
      expect(es_affiliate.image_search_label.name).to eq('Imágenes')
    end

    it 'should have active Navigation with position 0' do
      navigation = en_affiliate.image_search_label.navigation
      expect(navigation.position).to eq(100)
      expect(navigation).not_to be_is_active
    end
  end

  describe '#save' do
    it 'should not allow blank name' do
      image_search_label = en_affiliate.image_search_label
      image_search_label.update_attributes!(:name => '')
      expect(image_search_label.name).to eq('Images')

      image_search_label = es_affiliate.image_search_label
      image_search_label.update_attributes!(:name => '  ')
      expect(image_search_label.name).to eq('Imágenes')
    end
  end
end
