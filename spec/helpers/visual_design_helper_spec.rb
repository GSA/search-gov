describe VisualDesignHelper do
  describe '#render_affiliate_visual_design_value' do
    context 'when font_family is valid' do
      let(:visual_design_json) { { 'header_links_font_family' => 'tahoma' } }

      it 'renders that font_family' do
        expect(helper.render_affiliate_visual_design_value(visual_design_json, :header_links_font_family)).to eq('tahoma')
      end
    end

    context 'when font_family is missing' do
      it 'renders the default font_family' do
        expect(helper.render_affiliate_visual_design_value({}, :footer_and_results_font_family)).to eq('public-sans')
      end
    end
  end
end
