require 'spec_helper'

describe HostedAzureWebEngine do
  describe 'api namespacing' do
    it 'uses the AzureEngine namespace' do
      described_class.api_namespace.should eq(AzureEngine::NAMESPACE)
    end
  end

  describe '#execute_query' do
    context 'when response _next is present' do
      let(:engine) do
        HostedAzureWebEngine.new enable_highlighting: true,
                                 language: 'en',
                                 offset: 0,
                                 per_page: 20,
                                 query: 'healthy snack (site:usa.gov)'
      end

      subject(:response) { engine.execute_query }

      it 'sets results' do
        expect(response.results.count).to eq(20)
      end

      it 'sets fake total' do
        expect(response.total).to eq(21)
      end

      it 'highlights title and description' do
        result = response.results.first
        expect(result.title).to eq("Exercise and Eating \ue000Healthy\ue001 for Kids | Grades K - 5 | Kids.gov")
        expect(result.content).to eq("Exercise and Eating \ue000Healthy\ue001 for Kids | Grades K - 5 ... What gear do you need for a sport? See a list here")
        expect(result.unescaped_url).to eq('http://kids.usa.gov/exercise-and-eating-healthy/index.shtml')
      end
    end

    context 'when response _next is not present' do
      let(:engine) do
        HostedAzureWebEngine.new enable_highlighting: true,
                                 language: 'en',
                                 offset: 0,
                                 per_page: 20,
                                 query: 'healthy snack (site:usa.gov) (-site:www.usa.gov AND -site:kids.usa.gov)'
      end

      subject(:response) { engine.execute_query }

      it 'sets total' do
        expect(response.total).to eq(12)
      end
    end

    context 'when there are no results' do
      let(:engine) do
        HostedAzureWebEngine.new enable_highlighting: true,
                                 language: 'en',
                                 offset: 0,
                                 per_page: 20,
                                 query: 'mango smoothie (site:usa.gov)'
      end

      subject(:response) { engine.execute_query }

      it 'sets total' do
        expect(response.total).to eq(0)
      end
    end
  end
end
