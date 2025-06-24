# frozen_string_literal: true

describe MobileSearchHelper do
  describe '#eligible_for_commercial_results?' do
    context 'when search is not ImageSearch or BlendedSearch' do
      it 'returns false' do
        search = instance_double(NewsSearch, page: 1, per_page: 20, total: 5)
        expect(helper.eligible_for_commercial_results?(search)).to eq(false)
      end
    end
  end

  describe '#extra_pagination_params' do
    it 'returns nil for all search types' do
      search = instance_double(NewsSearch, page: 1, per_page: 20, total: 5)
      expect(helper.extra_pagination_params(search)).to be_nil
    end
  end
end
