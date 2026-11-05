# frozen_string_literal: true

describe MobileSearchHelper do
  describe '#eligible_for_commercial_results?' do
    context 'when search is not ImageSearch or BlendedSearch' do
      it 'returns false' do
        search = instance_double(Search, page: 1, per_page: 20, total: 5)
        expect(helper.eligible_for_commercial_results?(search)).to eq(false)
      end
    end
  end

  describe '#extra_pagination_params' do
    it 'returns nil' do
      expect(helper.extra_pagination_params(instance_double(Search))).to be_nil
    end
  end

  describe '#render_result_pages_links?' do
    it 'returns true for a filterable search' do
      expect(helper.render_result_pages_links?(BlendedSearch.allocate)).to be(true)
    end

    it 'returns false for other searches' do
      expect(helper.render_result_pages_links?(ImageSearch.allocate)).to be(false)
    end
  end
end
