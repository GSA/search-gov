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
end
