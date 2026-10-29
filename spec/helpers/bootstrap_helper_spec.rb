# frozen_string_literal: true

describe BootstrapHelper do
  describe '#pagination_label' do
    it 'returns the next label' do
      expect(helper.pagination_label(:next)).to eq('Next&nbsp;&raquo;')
    end

    it 'returns the previous label' do
      expect(helper.pagination_label(:prev)).to eq('&laquo;&nbsp;Previous')
    end
  end
end
