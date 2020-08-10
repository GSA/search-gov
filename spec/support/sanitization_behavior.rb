shared_examples_for 'a record that sanitizes attributes' do |attributes|
  let(:unsanitized_string) { '<b>foo</b><script>script</script>' }
  let(:params) do
    attributes.map{ |attribute| [attribute, unsanitized_string] }.to_h
  end
  let(:record) { described_class.new(params) }

  context 'before validation' do
    before { record.validate }

    it 'sanitizes the HTML' do
      attributes.each do |attribute|
        expect(record.send(attribute)).to eq 'foo'
      end
    end

    context 'when the attribute contains encodable entities' do
      let(:unsanitized_string) { 'foo & bar' }

      it 'encodes the entities' do
        attributes.each do |attribute|
          expect(record.send(attribute)).to eq 'foo &amp; bar'
        end
      end
    end
  end
end
