shared_examples 'a Bing V6 search' do
  it_behaves_like 'a Bing engine'

  describe '#params' do
    subject do
      described_class.new({
        filter: filter
      })
    end
    let(:filter) { nil }

    it 'uses the hard-coded APP_ID for AppId' do
      expect(subject.params[:AppId]).to eq(BingV6Search::APP_ID)
    end

    {
      nil => 'moderate',
      0 => 'off',
      1 => 'moderate',
      2 => 'strict',
      3 => 'moderate',
      4 => 'moderate',
      5 => 'moderate',
      6 => 'moderate',
      7 => 'moderate',
    }.each do |adult_filter, safe_search_value|
      context "when given adult filter #{adult_filter}" do
        let(:filter) { adult_filter }

        it "uses the '#{safe_search_value}' safeSearch value" do
          expect(subject.params[:safeSearch]).to eq(safe_search_value)
        end
      end
    end
  end

  describe '#execute_query' do
    subject(:execute_query) { described_class.new({ }).execute_query }

    before do
      stub_request(:get, %r{/api/v6/}).to_return({ body: bing_response_body })
    end

    context 'when an error is returned by bing' do
      let(:bing_response_body) { '{"_type": "ErrorResponse", "errors": [{"code": "ResourceAccessDenied", "message": "AppID does not have access to the Data source: ImageSearch"}]}' }

      it 'raises an exception' do
        expect { execute_query }.to raise_error('AppID does not have access to the Data source: ImageSearch')
      end
    end
  end

  describe 'api cache namespacing' do
    it 'uses the "bing_v6" namespace' do
      expect(subject.api_cache_namespace).to eq('bing_v6')
    end
  end
end
