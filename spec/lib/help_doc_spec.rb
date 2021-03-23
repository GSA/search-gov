require 'spec_helper'

describe HelpDoc do
  describe '.extract_article' do
    context 'when there is an error in retrieving the help doc' do
      it 'should respond with alert' do
        url = 'https://search.gov/manual/site-information.html'
        expect(described_class).to receive(:open).with(url).and_raise
        expect(described_class.extract_article(url)).to include('Unable to retrieve')
      end
    end
  end
end
