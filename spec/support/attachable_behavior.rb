shared_examples_for 'a class with attachable images' do
  include Attachable
  let(:my_id) { my_class.id }
  let(:attachment_types) { my_class.class.reflect_on_all_attachments.map(&:name) }

  describe '#set_attached_filepath' do
    let(:attachment_atts) do
      { io: Rails.root.join('spec/fixtures/images/dog.jpg').open,
        filename: 'dog.jpg',
        content_type: 'image/jpeg' }
    end

    it 'builds the correct filepaths before validation' do
      attachment_types.each do |attachment|
        my_class.send(attachment).attach(attachment_atts)
        my_class.validate

        expect(my_class.send(attachment).key).to eq("test/site/#{my_id}/#{attachment}/dog.jpg")
      end
    end
  end
end
