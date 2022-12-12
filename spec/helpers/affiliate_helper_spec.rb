# frozen_string_literal: true

require 'spec_helper'

describe AffiliateHelper do
  describe '#favicon_url' do
    context 'when a favicon URL is passed in' do
      let(:url) { '/custom_favicon.ico' }

      it 'returns the URL' do
        expect(favicon_url(url)).to eq(url)
      end
    end

    context 'when an empty string is passed in' do
      let(:url) { '' }

      it 'returns the default favicon' do
        expect(favicon_url(url)).to eq('/favicon_affiliate.ico')
      end
    end
  end
end
