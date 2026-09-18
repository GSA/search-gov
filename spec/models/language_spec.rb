describe Language do
  fixtures :languages, :affiliates
  it { is_expected.to have_many(:affiliates).inverse_of(:language) }
  it { is_expected.to validate_presence_of(:code) }
  it { is_expected.to validate_uniqueness_of(:code).case_insensitive }
  it { is_expected.to validate_presence_of(:name) }

  describe '.iso_639_1' do
    subject(:iso_639_1) { described_class.iso_639_1(language) }

    let(:language) { 'en' }

    it 'returns the two-letter iso-639-1 code' do
      expect(iso_639_1).to eq 'en'
    end

    it 'parses multiple formats' do
      %w[en-US EN-US EN].each do |language|
        expect(described_class.iso_639_1(language)).to eq 'en'
      end
    end

    context 'when the full language name is passed' do
      let(:language) { 'Arabic' }

      it { is_expected.to eq 'ar' }
    end

    context 'when the language cannot be found' do
      let(:language) { 'Klingon' }

      it { is_expected.to be_nil }
    end

    context 'when the language is nil' do
      let(:language) { nil }

      it { is_expected.to be_nil }
    end
  end
end
