describe MobileHelper do
  describe '#related_sites_dropdown_label' do
    context 'when label is present' do
      specify { expect(helper.related_sites_dropdown_label('foo')).to eq('foo') }
    end

    context 'when label is nil' do
      specify { expect(helper.related_sites_dropdown_label(nil)).to eq(I18n.t(:'searches.related_sites')) }
    end
  end

  describe '#search_results_by_text' do
    it 'returns the powered by text' do
      expect(helper.search_results_by_text('BWEB')).to eq('Powered by Search.gov')
    end
  end

  describe '#serp_attribution' do
    it 'renders the powered by partial' do
      expect(helper.serp_attribution('BWEB')).to have_content('Powered by Search.gov')
    end
  end

  describe '#pagination_link_separator' do
    it 'renders the current page' do
      expect(helper.pagination_link_separator(2)).to have_selector('span.current_page', text: 'Page 2')
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
