require 'spec_helper'

describe ElasticFederalRegisterDocument do
  let(:fr_noaa) { federal_register_agencies(:fr_noaa) }
  let(:fr_irs) { federal_register_agencies(:fr_irs) }

  describe '.search_for' do
    before do
      FederalRegisterDocument.all.each(&:save!)
      described_class.commit
    end

    context 'when there are results that are significant, rules, published recently, or comments still open' do
      it 'returns results in an easy to access structure' do
        search = described_class.search_for(federal_register_agency_ids: [fr_noaa.id, fr_irs.id],
                                            language: 'en',
                                            q: 'fish')

        expect(search.total).to eq 5
        expect(search.results.first).to be_instance_of(FederalRegisterDocument)
        expect(search.results.pluck('document_number')).not_to include '2022-12345'
      end

      it 'sorts results by comments_close_on in the descending order' do
        search = described_class.search_for(federal_register_agency_ids: [fr_noaa.id],
                                            language: 'en',
                                            q: 'foreign fishing')

        expect(search.total).to eq 5
        expect(search.results[0].document_number).to eq '2014-15173'
        expect(search.results[1].document_number).to eq '2014-15266'
        expect(search.results[2].document_number).to eq '2014-15269'
      end

      it 'groups results by docket ID ordered by published_date' do
        search = described_class.search_for(federal_register_agency_ids: [fr_noaa.id],
                                            language: 'en',
                                            q: 'hedge funds')
        expect(search.total).to eq 3
        expect(search.results[0].document_number).to eq '2013-17000'
        expect(search.results[1].document_number).to eq '2013-15000'
        expect(search.results[2].document_number).to eq '2014-25000'
      end

      context 'when there is a matching term in the abstract' do
        it 'shows the documents' do
          search = described_class.search_for(federal_register_agency_ids: [fr_noaa.id],
                                              language: 'en',
                                              q: 'protect')

          expect(search.total).to eq 1
          expect(search.results[0].document_number).to eq '2014-15238'
        end
      end

      context 'when the query contains document number' do
        it 'shows the documents' do
          search = described_class.search_for(federal_register_agency_ids: [fr_noaa.id],
                                              language: 'en',
                                              q: '2014-15238 marine')

          expect(search.total).to eq 1
          expect(search.results[0].document_number).to eq '2014-15238'
        end
      end

      context 'when those results get deleted' do
        before do
          FederalRegisterDocument.destroy_all
          described_class.commit
        end

        it 'returns zero results' do
          search = described_class.search_for(federal_register_agency_ids: [fr_noaa.id],
                                              language: 'en',
                                              q: 'fish')

          expect(search.total).to eq 0
          expect(search.results.size).to eq 0
        end
      end
    end

    context 'when there are not results that are significant, rules, published recently, or comments still open' do
      it 'does not return results' do
        search = described_class.search_for(federal_register_agency_ids: [fr_irs.id],
                                            language: 'en',
                                            q: 'fishing')

        expect(search.total).to eq 0
      end
    end
  end
end
