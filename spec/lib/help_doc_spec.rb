require 'spec_helper'

describe HelpDoc do
  describe '.extract_article' do
    context 'when there is an error in retrieving the help doc' do
      it 'should respond with alert' do
        url = 'https://search.gov/manual/site-information.html'
        HelpDoc.should_receive(:open).with(url).and_raise
        HelpDoc.extract_article(url).should include('Unable to retrieve')
      end
    end
  end
end
