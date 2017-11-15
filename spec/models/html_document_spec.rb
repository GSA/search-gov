require 'spec_helper'

describe HtmlDocument do
  let(:raw_document) { read_fixture_file("/html/page_with_metadata.html") }
  let(:url) { 'https://foo.gov/bar.html' }
  let(:valid_attributes) do
    { document: raw_document, url: url }
  end
  subject(:html_document) { HtmlDocument.new(valid_attributes) }
  let(:doc_without_description) { read_fixture_file("/html/page_with_no_links.html") }
  let(:doc_with_lang_subcode) { '<html lang="en-US"></html>' }
  let(:doc_without_language) { '<html>هذه الجملة باللغة العربية.</html>' }

  it_should_behave_like 'a web document'

  describe '#title' do
    subject(:title) { html_document.title }

    context 'when no title is available' do
      let(:raw_document) { read_fixture_file('/html/page_without_title.html') }

      it 'returns the url' do
        expect(title).to eq url
      end
    end

    context 'when an open graph title is available' do
      let(:raw_document) { read_fixture_file('/html/page_with_og_metadata.html') }

      it 'returns the open graph title' do
        expect(title).to eq 'My OG Title'
      end
    end
  end

  describe '#description' do
    subject(:description) { html_document.description }

    context 'when an open graph description is available' do
      let(:raw_document) { read_fixture_file('/html/page_with_og_metadata.html') }

      it 'returns the open graph description' do
        expect(description).to eq 'My OG Description'
      end
    end
  end

  describe '#created' do
    subject(:created) { html_document.created }

    it { should eq nil }

    context 'when the publication date is available' do
      let(:raw_document) { read_fixture_file('/html/page_with_og_metadata.html') }

      it { should eq "2015-07-02T10:12:32-04:00" }
     end
  end

  describe '#noindex?' do
    subject(:noindex) { html_document.noindex? }

    context 'when NOINDEX is specified' do
      let(:raw_document) do
        '<html><head><title>...</title><META NAME="ROBOTS" CONTENT="NOINDEX, NOFOLLOW"></head></html>'
      end

      it { should eq true }
    end

    context 'when NONE is specified' do
      let(:raw_document) do
        '<html><head><title>...</title><META NAME="ROBOTS" CONTENT="NONE"></head></html>'
      end

      it { should eq true }
    end

    context 'when NOINDEX is not specified' do
      let(:raw_document) do
        '<html><head><title>...</title><META NAME="ROBOTS" CONTENT="NOFOLLOW"></head></html>'
      end

      it { should eq false }
    end
  end

  describe 'parsed_content' do
    subject(:parsed_content) { html_document.parsed_content }

    context 'when the HTML contains whitespace' do
      let(:raw_document) do
        "<html><body><h1>Heading</h1>Body   text<p>More\t body  \ttext</p><br>Even more text</body></html>"
      end

      it 'combines line breaks and whitespace' do
        expect(parsed_content).to eq "Heading\nBody text\nMore body text\nEven more text"
      end
    end

    context 'when the HTML contains a bazillion elements' do
      let(:raw_document) { read_fixture_file('/html/bazillion_elements.html') }

      it 'returns the parsed content' do
        expect(parsed_content).to match(/Zwecker, Bruce H/)
      end
    end

    context 'when the html includes special characters' do
      let(:raw_document) { "<html>foo &amp; bar</html>" }

      it 'decodes the characters' do
        expect(parsed_content).to eq 'foo & bar'
      end
    end

    context 'when the html contains a comment' do
      let(:raw_document) { "<html><body>no comment<!-- blah --></body></html>" }

      it 'does not include the comment' do
        expect(parsed_content).not_to match(/blah/)
      end
    end

    context 'when the html contains a script' do
      let(:raw_document) { "no script<script>alert('OHAI')</script>" }

      it 'removes the script' do
        expect(parsed_content).to eq 'no script'
      end
    end

    context 'when the html contains style tags' do
      let(:raw_document) { "<style>h1 {color:red;}</style>no style" }

      it 'removes the style' do
        expect(parsed_content).to eq 'no style'
      end
    end

    context 'when a link includes a title' do
      let(:raw_document) do
        '<a href="/blog" title="Read the latest" class="menu__link">Latest News</a></li>'
      end

      it 'does not include the link title' do
        expect(parsed_content).to eq 'Latest News'
      end
    end

    context 'when the html includes invalid byte sequences' do
      let(:raw_document) { "<html><body>invalid bytes\xA7</body></html>" }

      it 'omits the invalid bytes' do
        expect(parsed_content).to eq 'invalid bytes'
      end
    end

    context 'when the html contains a main element' do
      let(:raw_document) do
        "<html><body>Body Content<main>Main content</main></body></html>"
      end

      it 'extracts the main content text' do
        expect(parsed_content).to eq 'Main content'
      end

      context 'when the main element is specified by a role' do
        let(:raw_document) do
          "<html><body>Body Content<div id='main-content' role='main'>Main content</div></body></html>"
        end

        it 'extracts the main content text' do
          expect(parsed_content).to eq 'Main content'
        end
      end
    end

    context 'when the html contains block-level elements' do
      let(:raw_document) do
        "<html><body>Body Content<article>Article Content</article></body></html>"
      end

      it 'inserts line breaks between the elements' do
        expect(parsed_content).to eq "Body Content\nArticle Content"
      end
    end
  end
end
