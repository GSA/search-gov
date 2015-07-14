require 'spec_helper'

describe HostedAzureWebEngine do
  fixtures :affiliates, :languages

  let(:affiliate) { affiliates(:usagov_affiliate) }

  before { affiliate.site_domains.create!(domain: 'usa.gov') }

  describe '#execute_query' do
    context 'when response _next is present' do
      let(:engine) do
        HostedAzureWebEngine.new affiliate: affiliate,
                                 offset: 0,
                                 per_page: 20,
                                 query: 'healthy snack (site:usa.gov)'
      end

      subject(:response) { engine.execute_query }

      it 'returns limited results' do
        expect(response.results.count).to eq(20)
      end

      it 'returns fake total' do
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
        HostedAzureWebEngine.new affiliate: affiliate,
                                 offset: 0,
                                 per_page: 20,
                                 query: 'healthy snack (site:usa.gov) (-site:www.usa.gov AND -site:kids.usa.gov)'
      end

      before do
        affiliate.excluded_domains.create!(domain: 'www.usa.gov')
        affiliate.excluded_domains.create!(domain: 'kids.usa.gov')
      end

      subject(:response) { engine.execute_query }

      it 'returns total' do
        expect(response.total).to eq(12)
      end
    end
  end
end
