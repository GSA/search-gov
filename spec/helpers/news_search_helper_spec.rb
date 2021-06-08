# frozen_string_literal: true

describe NewsSearchHelper do
  describe '#current_time_filter_description' do
    subject(:current_time_filter_description) do
      helper.current_time_filter_description(search)
    end

    let(:tbs) { nil }
    let(:since) { nil }
    let(:until_time) { nil }
    let(:search) do
      instance_double(NewsSearch, tbs: tbs, since: since, until: until_time)
    end

    it { is_expected.to eq 'Any time' }

    context 'when searching by the most recent month' do
      let(:tbs) { 'm' }

      it { is_expected.to eq 'Last month' }
    end

    context 'when searching after a time' do
      let(:since) { Time.utc(2021, 5, 1) }

      before { travel_to(Time.utc(2021, 6, 3)) }

      after { travel_back }

      it 'describes a range from the given date to the current date' do
        expect(current_time_filter_description).to eq 'May 1, 2021 - Jun 3, 2021'
      end
    end

    context 'when searching before a time' do
      let(:until_time) { Time.utc(2021, 6, 3) }

      it 'describes a range up to the given date' do
        expect(current_time_filter_description).to eq 'Before Jun 3, 2021'
      end
    end
  end
end
