shared_examples 'a Bing engine' do
  describe '#params' do
    subject do
      described_class.new({
        offset: :offset,
        limit: :limit,
        query: :query,
        language: language,
        password: :password,
      })
    end
    let(:language) { 'da' }
    before { allow(Language).to receive(:bing_market_for_code).with('da').and_return('da-DK') }

    it 'gets offset from options' do
      expect(subject.params[:offset]).to eq(:offset)
    end

    it 'gets count from options' do
      expect(subject.params[:count]).to eq(:limit)
    end

    it 'gets q from options' do
      expect(subject.params[:q]).to eq(:query)
    end

    it 'gets mkt from Language.bing_market_for_code' do
      expect(subject.params[:mkt]).to eq('da-DK')
    end
  end
end
