shared_examples 'a web document' do
  let(:web_document) { described_class.new(valid_attributes) }

  describe 'web document interface' do
    %i[title description parsed_content language keywords created changed].each do |method|
      it "responds to #{method}" do
        expect(web_document.respond_to?(method)).to eq true
      end
    end
  end

  describe 'initialization' do
    it 'requires a document' do
      expect{ described_class.new(valid_attributes.except(:document)) }
        .to raise_error(ArgumentError, 'missing keyword: document')
    end

    it 'requires a url' do
      expect{ described_class.new(valid_attributes.except(:url)) }
        .to raise_error(ArgumentError, 'missing keyword: url')
    end
  end

  describe '#title' do
    subject(:title) { web_document.title }

    it { is_expected.to eq 'My Title' }
  end

  describe '#description' do
    subject(:description) { web_document.description }

    it { is_expected.to eq 'My description' }

    context 'when the description is missing' do
      let(:raw_document) { doc_without_description }

      it { is_expected.to eq nil }
    end
  end

  describe '#parsed_content' do
    subject(:parsed_content) { web_document.parsed_content }

    it { is_expected.to match(/This is my headline.*This is my content/m) }
  end

  describe '#language' do
    subject(:language) { web_document.language }

    it { is_expected.to eq 'en' }

    context 'when the language includes a sub-code' do
      let(:raw_document) { doc_with_lang_subcode }

      it 'returns the ISO 639-1 two-letter code' do
        expect(language).to eq 'en'
      end
    end

    context 'when the language is missing' do
      let(:raw_document) { doc_without_language }

      before { web_document.metadata.remove!('language') }

      it 'detects the language' do
        expect(language).to eq 'ar'
      end
    end
  end

  describe '#keywords' do
    subject(:keywords) { web_document.keywords }

    it { is_expected.to eq 'this, that' }
  end
end
