describe VisualDesignHelper do
  describe '#show_results_format?' do
    context 'when affiliate gets blended results' do
      let(:affiliate) { affiliates(:blended_affiliate) }

      it 'is true' do
        expect(helper.show_results_format?(affiliate)).to be(true)
      end
    end

    context 'when affiliate search engine is BingV7' do
      let(:affiliate) { affiliates(:bing_v7_affiliate) }

      it 'is false' do
        expect(helper.show_results_format?(affiliate)).to be(false)
      end
    end
  end

  describe '#render_logo_alt_text' do
    context 'when logo alt_text is present' do
      let(:metadata) { { 'alt_text' => 'A small screenshot' } }

      it 'renders that alt_text' do
        expect(helper.render_logo_alt_text(metadata)).to eq('A small screenshot')
      end
    end

    context 'when logo alt_text is not present' do
      let(:metadata) { { 'some_other_key' => 'Some other value' } }

      it 'renders the default alt_text' do
        expect(helper.render_logo_alt_text(metadata)).to be_nil
      end
    end
  end
end
