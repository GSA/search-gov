require 'spec_helper'

describe SearchModuleCtr do
  fixtures :search_modules

  let(:search_module_ctr) { described_class.new(7) }

  describe '#search_module_ctrs' do
    context 'when stats are available for the range' do
      let(:historical_mb_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/historical_module_breakdown.json")) }
      let(:mb_json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/module_breakdown.json")) }

      before do
        expect(Es::ELK.client_reader).to receive(:search).
          with(hash_including(size: 0)).
          and_return(historical_mb_json_response, mb_json_response)
      end

      it 'should return collection of SearchModuleCtrStat instances ordered by decr search+click count' do
        stats = search_module_ctr.search_module_ctrs
        expect(stats.first.name).to eq(search_modules(:bweb).display_name)
        expect(stats.first.tag).to eq(search_modules(:bweb).tag)
        expect(stats.first.historical.impressions).to eq(197_612)
        expect(stats.first.historical.clicks).to eq(149_436)
        expect(stats.first.recent.impressions).to eq(97_612)
        expect(stats.first.recent.clicks).to eq(49_436)

        expect(stats.last.name).to eq(search_modules(:bbg).display_name)
        expect(stats.last.tag).to eq(search_modules(:bbg).tag)
        expect(stats.last.historical.impressions).to eq(19_251)
        expect(stats.last.historical.clicks).to eq(11_391)
        expect(stats.last.recent.impressions).to eq(9251)
        expect(stats.last.recent.clicks).to eq(1391)
      end

    end

    context 'when no stats are available for the daterange' do
      before do
        expect(Es::ELK.client_reader).to receive(:search).twice.and_return nil
      end

      it 'should return an empty array' do
        stats = search_module_ctr.search_module_ctrs
        expect(stats).to eq([])
      end
    end
  end

end
