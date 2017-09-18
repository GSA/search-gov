shared_examples 'a web document' do
  let(:web_document) { described_class.new(valid_attributes) }

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

    it { should eq 'My Title' }
  end

  describe '#description' do
    subject(:description) { web_document.description }

    it { should eq 'My description' }

    context 'when the description is missing' do
      let(:web_document) do
        described_class.new(valid_attributes.merge(document: doc_without_description))
      end

      it { should eq nil }
    end
  end

  describe '#parsed_content' do
    subject(:parsed_content) { web_document.parsed_content }

    it { should match(/This is my headline.*This is my content/m) }
  end

  describe '#language' do
    subject(:language) { web_document.language }

    it { should eq 'en' }

    context 'when the language includes a sub-code' do
      let(:web_document) do
        described_class.new(valid_attributes.merge(document: doc_with_lang_subcode))
      end

      it 'returns the ISO 639-1 two-letter code' do
        expect(language).to eq 'en'
      end
    end
  end

  describe '#keywords' do
    subject(:keywords) { web_document.keywords }

    it { should eq 'this, that' }
  end
end
