require 'spec_helper'

describe SaytController, type: :request do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }
  let(:results) { double('results', to_json: 'some json string') }
  let(:search) { double(SaytSearch, results: results) }

  describe '#index' do
    context 'when sanitized query is empty' do
      it 'returns empty string' do
        get '/sayt', q: ' \\ '
        expect(response.body).to eq('')
      end
    end

    context 'when sanitized_query is not empty and params[:name] is valid' do
      it 'should do SaytSearch' do
        expect(Affiliate).to receive(:find_by_name_and_is_sayt_enabled).with(affiliate.name, true).and_return(affiliate)
        expect(SaytSearch).to receive(:new).
            with(hash_including(affiliate_id: affiliate.id,
                                query: 'lorem ipsum',
                                extras: false,
                                number_of_results: 5)).
            and_return(search)

        get '/sayt', q: 'lorem \\ ipsum', name: affiliate.name
        expect(response.body).to eq('some json string')
      end
    end

    context 'when sanitized_query, params[:name] and params[:extras] are present' do
      it 'should do SaytSearch' do
        expect(Affiliate).to receive(:find_by_name_and_is_sayt_enabled).with(affiliate.name, true).and_return(affiliate)

        expect(SaytSearch).to receive(:new).
            with(hash_including(:affiliate_id => affiliate.id,
                                :query => 'lorem ipsum',
                                :extras => true,
                                number_of_results: 5)).
            and_return(search)

        get '/sayt', q: 'lorem \\ ipsum', name: affiliate.name, extras: true
        expect(response.body).to eq('some json string')
      end
    end

    context 'when sanitized_query is not empty and params[:name] is not valid' do
      it 'should return blank' do
        expect(SaytSearch).not_to receive(:new)

        get '/sayt', q: 'lorem \\ ipsum', name: 'invalid'
        expect(response.body).to eq('')
      end
    end

    context 'when sanitized_query is not empty and params[:aid] is valid' do
      it 'should do SaytSearch' do
        expect(Affiliate).to receive(:find_by_id_and_is_sayt_enabled).with(affiliate.id.to_s, true).and_return(affiliate)
        expect(SaytSearch).to receive(:new).
            with(hash_including(affiliate_id: affiliate.id,
                                query: 'lorem ipsum',
                                extras: false,
                                number_of_results: 5)).
            and_return(search)

        get '/sayt', :q => 'lorem \\ ipsum', :aid => affiliate.id
        expect(response.body).to eq('some json string')
      end
    end

    context 'when sanitized_query, params[:aid] and params[:extras] are present' do
      it 'should do SaytSearch' do
        expect(Affiliate).to receive(:find_by_id_and_is_sayt_enabled).with(affiliate.id.to_s, true).and_return(affiliate)
        expect(SaytSearch).to receive(:new).
            with(hash_including(affiliate_id: affiliate.id,
                                query: 'lorem ipsum',
                                extras: true,
                                number_of_results: 5)).
            and_return(search)

        get '/sayt', :q => 'lorem \\ ipsum', :aid => affiliate.id, :extras => 'true'
        expect(response.body).to eq('some json string')
      end
    end

    context 'when sanitized_query is not empty and params[:aid] is not valid' do
      it 'should return blank' do
        expect(Affiliate).to receive(:find_by_id_and_is_sayt_enabled).with('0', true).and_return(nil)
        expect(SaytSearch).not_to receive(:new)

        get '/sayt', :q => 'lorem // ipsum', :aid => 0
        expect(response.body).to eq('')
      end
    end
  end
end
