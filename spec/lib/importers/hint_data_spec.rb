require 'spec_helper'

describe HintData do
  fixtures :hints

  describe '.reload' do
    it 'creates and updates hints' do
      json_str = Rails.root.join('spec/fixtures/json/hints.json').read
      expect(DocumentFetcher).to receive(:fetch).and_return(body: json_str)
      described_class.reload

      expect(Hint.count).to eq(6)

      hint = Hint.find_by_name('document_collection.name')
      expect(hint.value).to be_nil

      hint = Hint.find_by_name('site_domain.domain')
      expect(hint.value).to match(/Use www for results from www\.agency\.gov only/)

      hint = Hint.find_by_name('user.first_name')
      expect(hint.value).to match(/Please enter first name/)
      expect(Hint.find_by_name('obsolete_key')).to be_nil

      hint = Hint.find_by_name('user.last_name')
      expect(hint.value).to match(/Please enter last name/)
      expect(Hint.find_by_name('obsolete_key')).to be_nil
    end

    context 'when DocumentFetcher.fetch returns with error' do
      before do
        expect(DocumentFetcher).to receive(:fetch).
          and_return(error: 'Unable to fetch url')
      end

      it 'returns error' do
        status = described_class.reload
        expect(status[:error]).to match(/Unable to fetch/)
      end
    end

    context 'when JSON.parse raises error' do
      before do
        expect(DocumentFetcher).to receive(:fetch).and_return(body: '[bad json}')
      end

      it 'returns error' do
        expect(Rails.logger).to receive(:error).with(/HintData\.reload failed/)
        status = described_class.reload
        expect(status[:error]).to match(/unexpected token/)
      end
    end
  end
end
