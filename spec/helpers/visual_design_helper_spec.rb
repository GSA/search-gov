describe VisualDesignHelper do
  describe '#render_affiliate_visual_design_value' do
    context 'when font_family is valid' do
      let(:visual_design_json) do
        { 'header_links_font_family' => "'Helvetica Neue', 'Helvetica', 'Roboto', 'Arial', sans-serif" }
      end

      it 'renders that font_family' do
        expect(helper.render_affiliate_visual_design_value(visual_design_json, :header_links_font_family)).
          to match(/Helvetica/)
      end
    end

    context 'when font_family is missing' do
      it 'renders the default font_family' do
        expect(helper.render_affiliate_visual_design_value({}, :footer_and_results_font_family)).
          to match(/Public Sans Web/)
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
        expect(helper.render_logo_alt_text(metadata)).to eq('Logo')
      end
    end
  end
end
