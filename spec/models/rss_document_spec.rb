require 'spec_helper'

describe RssDocument do
  let(:content) do
    File.open(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml')
  end
  let(:document) { described_class.new(content) }

  describe 'validations' do
    context 'when the document is not valid rss' do
      subject(:document) { described_class.new('invalid') }

      it { is_expected.not_to be_valid }

      it 'reports the error' do
        document.valid?
        expect(document.errors[:base]).to eq(['invalid rss'])
      end
    end
  end

  describe '#feed_type' do
    it 'is rss' do
      expect(document.feed_type).to eq(:rss)
    end

    context "when 'feed'" do
      let(:content) { File.open(Rails.root.to_s + '/spec/fixtures/rss/atom_feed.xml') }

      it 'is atom' do
        expect(document.feed_type).to eq(:atom)
      end
    end
  end

  describe '#language' do
    it 'returns the first two letters downcased (e.g., es/en)' do
      expect(document.language).to eq('en')
    end

    context 'when the document does not contain a language element' do
      let(:content) do
        File.open(Rails.root.to_s + '/spec/fixtures/rss/empty.xml')
      end

      it 'returns nil' do
        expect(document.language).to eq(nil)
      end
    end
  end

  describe '#elements' do
    context 'when the type is rss' do
      let(:rss_elements) do
        { item: 'item',
          body: 'content:encoded',
          pubDate: %w(pubDate),
          link: %w(link),
          title: 'title',
          guid: 'guid',
          contributor: './/dc:contributor',
          publisher: './/dc:publisher',
          subject: './/dc:subject',
          description: %w(description),
          media_content: './/media:content[@url]',
          media_description: './media:description',
          media_text: './/media:text',
          media_thumbnail_url: './/media:thumbnail/@url' }.freeze
      end
      before { allow(document).to receive(:feed_type).and_return(:rss) }

      it 'returns rss elements' do
        expect(document.elements).to eq(rss_elements)
      end
    end

    context 'when the type is atom' do
      let(:atom_elements) do
        { item: 'xmlns:entry',
          pubDate: %w(xmlns:updated xmlns:published),
          link: %w(xmlns:link[@rel='alternate'][@href]/@href xmlns:link/@href),
          title: 'xmlns:title',
          guid: 'xmlns:id',
          description: %w(xmlns:content xmlns:summary) }.freeze
      end
      before { allow(document).to receive(:feed_type).and_return(:atom) }

      it 'returns atom elements' do
        expect(document.elements).to eq(atom_elements)
      end
    end
  end

  describe '#items' do
    it 'returns the items' do
      expect(document.items.count).to eq(3)
    end

    context 'when the type is atom' do
      let(:content) { File.open(Rails.root.to_s + '/spec/fixtures/rss/atom_feed.xml') }

      it 'returns the items' do
        expect(document.items.count).to eq(25)
      end
    end
  end
end
