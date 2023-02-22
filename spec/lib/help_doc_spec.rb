# frozen_string_literal: true

describe HelpDoc do
  describe '.extract_article' do
    context 'when there is an error in retrieving the help doc' do
      it 'responds with an alert' do
        url = 'https://search.gov/manual/site-information.html'
        allow(described_class).to receive(:open).with(url).and_raise
        expect(described_class.extract_article(url)).to include('Unable to retrieve')
      end
    end

    context 'when the help doc exists' do
      it 'returns that doc' do
        url = 'https://search.gov/admin-center/dashboard/settings.html'
        expect(described_class.extract_article(url)).to include('Editing Your Site Settings')
      end
    end
  end
end
