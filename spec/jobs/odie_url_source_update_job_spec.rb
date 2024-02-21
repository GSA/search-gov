# frozen_string_literal: true

describe OdieUrlSourceUpdateJob do
  let(:affiliate) { affiliates('blended_affiliate') }

  before do
    3.times do |i|
      IndexedDocument.create(title: "Indexed Document #{i}",
                             url: "https://www.uscis.gov/sites/default/files/#{i}.pdf",
                             source: 'rss',
                             affiliate: affiliate)
    end
  end

  it_behaves_like 'a searchgov job'

  describe '#perform' do
    let(:other_affiliate) { affiliates('bing_v7_affiliate') }
    let(:perform) do
      subject.perform(affiliate: affiliate)
    end

    it 'updates the rss source for that affiliate' do
      perform
      affiliate.indexed_documents.each do |document|
        expect(document.source).to eq('manual')
      end
    end

    it 'does not update the source for other affiliates' do
      perform
      other_affiliate.indexed_documents.each do |document|
        expect(document.source).to eq('rss')
      end
    end
  end
end
