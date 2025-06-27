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
end
