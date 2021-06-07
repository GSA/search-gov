require 'spec_helper'

describe NewsSearchHelper do
  describe '#render_current_time_filter' do
    context 'when since date equals until date' do
      let(:search) { double(NewsSearch, tbs: nil, since: Time.parse('2013-1-9'), until: Time.parse('2013-1-9')) }

      it 'should render only the day' do
        expect(helper.render_current_time_filter(search)).to eq('<span class="current-label">Jan 9, 2013</span>')
      end
    end

    context 'when since is present and until is nil' do
      let(:search) { double(NewsSearch, tbs: nil, since: Time.parse('2013-1-9'), until: nil) }

      context 'when locale is en' do
        before { expect(Date).to receive(:current).and_return(Date.new(2013, 1, 20)) }

        it 'should render #{since} - #{current}' do
          expect(helper.render_current_time_filter(search)).to eq('<span class="current-label">Jan 9, 2013 - Jan 20, 2013</span>')
        end
      end

      context 'when locale is es' do
        before do
          expect(Date).to receive(:current).and_return(Date.new(2013, 1, 20))
          I18n.locale = :es
        end

        after { I18n.locale = I18n.default_locale }

        it 'should render #{since} - #{current}' do
          expect(helper.render_current_time_filter(search)).to eq('<span class="current-label">ene 9, 2013 - ene 20, 2013</span>')
        end
      end
    end

    context 'when since is nil and until is present' do
      let(:search) { double(NewsSearch, tbs: nil, since: nil, until: Time.parse('2013-1-9')) }

      context 'when locale is en' do
        it 'should render the Before #{day}' do
          expect(helper.render_current_time_filter(search)).to eq('<span class="current-label">Before Jan 9, 2013</span>')
        end
      end

      context 'when locale is es' do
        before { I18n.locale = :es }
        after { I18n.locale = I18n.default_locale }

        it 'should render the Antes de #{day}' do
          expect(helper.render_current_time_filter(search)).to eq('<span class="current-label">Antes de ene 9, 2013</span>')
        end
      end
    end
  end

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
