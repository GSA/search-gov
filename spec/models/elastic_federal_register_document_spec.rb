require 'spec_helper'

describe ElasticFederalRegisterDocument do
  fixtures :federal_register_agencies, :federal_register_documents

  let!(:fr_noaa) { federal_register_agencies(:fr_noaa) }

  # Temporarily disabling these specs during ES56 upgrade
  # https://cm-jira.usa.gov/browse/SRCH-817
  pending '.search_for' do
    before do
      FederalRegisterDocument.all.each(&:save!)
      ElasticFederalRegisterDocument.commit
    end

    context 'when there are results that are significant, rules, published recently, or comments still open' do
      it 'returns results in an easy to access structure' do
        search = ElasticFederalRegisterDocument.search_for(federal_register_agency_ids: [fr_noaa.id],
                                                           language: 'en',
                                                           q: 'fish')

        expect(search.total).to eq 5
        expect(search.results.first).to be_instance_of(FederalRegisterDocument)
      end

      it 'sorts results by comments_close_on in the descending order' do
        search = ElasticFederalRegisterDocument.search_for(federal_register_agency_ids: [fr_noaa.id],
                                                           language: 'en',
                                                           q: 'foreign fishing')

        expect(search.total).to eq 5
        expect(search.results[0].document_number).to eq '2014-15173'
        expect(search.results[1].document_number).to eq '2014-15266'
        expect(search.results[2].document_number).to eq '2014-15269'
      end

      it 'groups results by docket ID ordered by published_date' do
        search = ElasticFederalRegisterDocument.search_for(federal_register_agency_ids: [fr_noaa.id],
                                                           language: 'en',
                                                           q: 'hedge funds')
        expect(search.total).to eq 3
        expect(search.results[0].document_number).to eq '2013-17000'
        expect(search.results[1].document_number).to eq '2013-15000'
        expect(search.results[2].document_number).to eq '2014-25000'
      end

      context 'when there is a matching term in the abstract' do
        it 'shows the documents' do
          search = ElasticFederalRegisterDocument.search_for(federal_register_agency_ids: [fr_noaa.id],
                                                             language: 'en',
                                                             q: 'protect')

          expect(search.total).to eq 1
          expect(search.results[0].document_number).to eq '2014-15238'
        end
      end

      context 'when the query contains document number' do
        it 'shows the documents' do
          search = ElasticFederalRegisterDocument.search_for(federal_register_agency_ids: [fr_noaa.id],
                                                             language: 'en',
                                                             q: '2014-15238 marine')

          expect(search.total).to eq 1
          expect(search.results[0].document_number).to eq '2014-15238'
        end
      end

      context 'when those results get deleted' do
        before do
          FederalRegisterDocument.destroy_all
          ElasticFederalRegisterDocument.commit
        end

        it 'returns zero results' do
          search = ElasticFederalRegisterDocument.search_for(federal_register_agency_ids: [fr_noaa.id],
                                                             language: 'en',
                                                             q: 'fish')

          expect(search.total).to eq 0
          expect(search.results.size).to eq 0
        end
      end

    end
  end
end
