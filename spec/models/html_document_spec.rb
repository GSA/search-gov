# frozen_string_literal: true

describe HtmlDocument do
  subject(:html_document) { described_class.new(**valid_attributes) }

  let(:raw_document) { read_fixture_file('/html/page_with_metadata.html') }
  let(:url) { 'https://foo.gov/bar.html' }
  let(:valid_attributes) do
    { document: raw_document, url: url }
  end
  let(:doc_with_dc_data) { read_fixture_file('/html/page_with_dc_metadata.html') }

  it_behaves_like 'a web document' do
    let(:doc_without_description) { read_fixture_file('/html/page_with_no_links.html') }
    let(:doc_with_lang_subcode) { '<html lang="en-US"></html>' }
    let(:doc_without_language) { '<html>هذه الجملة باللغة العربية.</html>' }
  end

  describe '#title' do
    subject(:title) { html_document.title }

    context 'when no title is available' do
      let(:raw_document) { read_fixture_file('/html/page_without_title.html') }

      it 'returns the url' do
        expect(title).to eq url
      end
    end

    context 'when only an open graph title is available' do
      let(:raw_document) do
        '<html><head><meta property="og:title" content="My OG Title" /></head><body></body></html>'
      end

      it 'returns the open graph title' do
        expect(title).to eq 'My OG Title'
      end
    end

    context 'when there is only an open graph title and it is parsed as empty' do
      let(:raw_document) do
        '<html><head><meta property="og:title" content=""Pull-a-Part" shop enhances readiness, saves money" /></head><body></body></html>'
      end

      it 'returns the url' do
        expect(title).to eq url
      end
    end

    context 'when only an html title is available' do
      let(:raw_document) do
        '<html><head><title>My Title</title></head><body></body></html>'
      end

      it 'returns the html title' do
        expect(title).to eq 'My Title'
      end
    end

    context 'when the html <title> tag is empty' do
      let(:raw_document) do
        '<html><head><title></title></head><body></body></html>'
      end

      it 'returns the url' do
        expect(title).to eq url
      end
    end

    context 'when both html and og titles are available' do
      let(:raw_document) do
        '<html><head><title>Long Looong Title</title><meta property="og:title" content="Short Title" /></head><body></body></html>'
      end

      it 'returns the longer title' do
        expect(title).to eq 'Long Looong Title'
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

    context 'when a Dublin Core description is available' do
      let(:raw_document) { doc_with_dc_data }

      it 'returns the Dublin Core description' do
        expect(description).to eq 'My DC Description'
      end
    end
  end

  describe '#created' do
    subject(:created) { html_document.created }

    it { is_expected.to be nil }

    context 'when the Open Graph publication date is available' do
      let(:raw_document) { read_fixture_file('/html/page_with_og_metadata.html') }

      it { is_expected.to eq Time.parse('2015-07-02T10:12:32-04:00') }
    end

    context 'when the Dublin Core date is available' do
      let(:raw_document) { doc_with_dc_data }

      it { is_expected.to eq Time.parse('02/16/2018 7:48 AM') }
    end

    context 'when the Dublin Core date created is available' do
      let(:raw_document) do
        <<~HTML
          <html lang="en">
            <head>
              <title>My Title</title>
              <meta name="dc.date.created" content="01/01/2020 12:01 AM"/>
            </head>
          </html>
        HTML
      end

      it { is_expected.to eq Time.parse('01/01/2020 12:01 AM') }
    end

    context 'when the Dublin Core Terms created is available' do
      let(:raw_document) do
        <<~HTML
          <html lang="en">
            <head>
              <title>My Title</title>
              <meta name="dcterms.created" content="01/01/2021 12:01 PM"/>
            </head>
          </html>
        HTML
      end

      it { is_expected.to eq Time.parse('01/01/2021 12:01 PM') }
    end

    context 'when all date created sources are present, Open Graph publication date wins' do
      let(:raw_document) do
        <<~HTML
          <html lang="en">
            <head>
              <title>My Title</title>
              <meta property="article:published_time" content="2015-07-02T10:12:32-04:00" />
              <meta name="dc.date" content="02/16/2018 7:48 AM"/>
              <meta name="dc.date.created" content="01/01/2020 12:01 AM"/>
              <meta name="dcterms.created" content="01/01/2021 12:01 PM"/>
            </head>
          </html>
        HTML
      end

      it { is_expected.to eq Time.zone.parse('2015-07-02T10:12:32-04:00') }
    end

    context 'when the Dublin Core date is a year' do
      let(:raw_document) do
        '<html><head><meta name="DC.date" content="2018"/></head></html>'
      end

      it { is_expected.to be nil }
    end
  end

  describe '#changed' do
    subject(:changed) { html_document.changed }

    context 'when a creation date is available but not a modification date' do
      let(:raw_document) do
        <<~HTML
          <meta property="article:published_time" content="2013-09-17T05:59:00+01:00"/>
          <meta property="article:modified_time" content=""/>
        HTML
      end

      it 'defaults to the created date' do
        expect(changed).to eq Time.parse('2013-09-17T05:59:00+01:00')
      end
    end

    context 'when the modification date is available' do
      let(:raw_document) { read_fixture_file('/html/page_with_og_metadata.html') }

      it { is_expected.to eq Time.parse('2017-03-30T13:18:28-04:00') }
    end
  end

  describe '#audience' do
    subject(:audience) { html_document.audience }

    context 'when a dcterms audience is available' do
      let(:raw_document) { doc_with_dc_data }

      it { is_expected.to eq 'dcterms audience' }
    end
  end

  describe '#image_url' do
    subject(:image_url) { html_document.image_url }

    context 'when an og:image is available' do
      let(:raw_document) { read_fixture_file('/html/page_with_og_metadata.html') }

      it { is_expected.to eq 'http://www.foo.gov/og_image.jpg' }
    end
  end

  describe '#content_type' do
    subject(:content_type) { html_document.content_type }

    context 'when a dc content type is available' do
      let(:raw_document) { doc_with_dc_data }

      it { is_expected.to eq 'dc type' }
    end

    context 'when a dcterms content type is available' do
      let(:raw_document) do
        <<~HTML
          <html lang="en">
            <head>
              <title>My Title</title>
              <meta name="dcterms.type" content="dcterms type"/>
            </head>
          </html>
        HTML
      end

      it { is_expected.to eq 'dcterms type' }
    end

    context 'when an og:type is available' do
      let(:raw_document) { read_fixture_file('/html/page_with_og_metadata.html') }

      it { is_expected.to eq 'video.movie' }
    end

    context 'when all content type sources are available' do
      let(:raw_document) do
        <<~HTML
          <html lang="en">
            <head>
              <title>My Title</title>
              <meta name="DC.type" content="dc type"/>
              <meta name="dcterms.type" content="dcterms type"/>
              <meta name="og:type" content="video.movie">
            </head>
          </html>
        HTML
      end

      it { is_expected.to include('dc type') }
      it { is_expected.to include('dcterms type') }
      it { is_expected.to include('video.movie') }
    end

    context 'when types are duplicated' do
      let(:raw_document) do
        <<~HTML
          <html lang="en">
            <head>
              <title>My Title</title>
              <meta name="dcterms.type" content="type"/>
              <meta name="dc.type" content="type"/>
              <meta property="og:type" content="type" />
            </head>
          </html>
        HTML
      end

      it { is_expected.to eq('type') }
    end
  end

  describe '#searchgov_custom' do
    context 'when a searchgov_custom1 is available' do
      subject(:searchgov_custom1) { html_document.searchgov_custom(1) }

      it { is_expected.to eq 'Custom 1' }
    end

    context 'when a searchgov_custom2 is available' do
      subject(:searchgov_custom2) { html_document.searchgov_custom(2) }

      it { is_expected.to eq 'Custom 2' }
    end

    context 'when a searchgov_custom3 is available' do
      subject(:searchgov_custom3) { html_document.searchgov_custom(3) }

      it { is_expected.to eq 'Custom 3' }
    end

    context 'when an invalid searchgov_custom is supplied' do
      subject(:searchgov_custom1) { html_document.searchgov_custom('word') }

      it { is_expected.to be_nil }
    end

    context 'when a searchgov_custom greater than 3 is supplied' do
      subject(:searchgov_custom4) { html_document.searchgov_custom(4) }

      it { is_expected.to be_nil }
    end
  end

  describe '#keywords' do
    subject(:keywords) { html_document.keywords }

    context 'when a Dublin Core subject is available' do
      let(:raw_document) { doc_with_dc_data }

      it { is_expected.to eq 'One Subject, Another Subject' }
    end
  end

  describe '#noindex?' do
    subject(:noindex) { html_document.noindex? }

    context 'when NOINDEX is specified' do
      let(:raw_document) do
        '<html><head><title>...</title><META NAME="ROBOTS" CONTENT="NOINDEX, NOFOLLOW"></head></html>'
      end

      it { is_expected.to eq true }
    end

    context 'when NONE is specified' do
      let(:raw_document) do
        '<html><head><title>...</title><META NAME="ROBOTS" CONTENT="NONE"></head></html>'
      end

      it { is_expected.to eq true }
    end

    context 'when NOINDEX is not specified' do
      let(:raw_document) do
        '<html><head><title>...</title><META NAME="ROBOTS" CONTENT="NOFOLLOW"></head></html>'
      end

      it { is_expected.to eq false }
    end
  end

  describe '#parsed_content' do
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

    context 'when the HTML contains a table' do
      let(:raw_document) do
        <<~HTML
          <table>
            <tr>
              <td style="font-weight:bold">A</td><td>B</td>
              <TD>C</TD>
            </tr>
            <tr>
              <td>D</td><td>E</td>
              <TD>F</TD>
            </tr>
          </table>
        HTML
      end

      it { is_expected.to eq "A B C \n D E F " }
    end

    context 'when the html includes special characters' do
      let(:raw_document) { '<html>foo &amp; bar</html>' }

      it 'decodes the characters' do
        expect(parsed_content).to eq 'foo & bar'
      end
    end

    context 'when the html contains a comment' do
      let(:raw_document) { '<html><body>no comment<!-- blah --></body></html>' }

      it 'does not include the comment' do
        expect(parsed_content).not_to match(/blah/)
      end
    end

    context 'when the html contains a script' do
      let(:raw_document) do
        '<html><body>no script<script>alert("OHAI")</script></body></html>'
      end

      it 'removes the script' do
        expect(parsed_content).to eq 'no script'
      end
    end

    context 'when the html contains style tags' do
      let(:raw_document) do
        '<html><body><style>h1 {color:red;}</style>no style</body></html>'
      end

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

      context 'when the html can be force-encoded to UTF-8' do
        let(:raw_document) { String.new('jubilación además', encoding: 'ASCII-8BIT') }

        it 'encodes the html as UTF-8' do
          expect(parsed_content).to include 'jubilación además'
        end
      end
    end

    context 'when the html contains a main element' do
      let(:raw_document) do
        '<html><body>Body Content<main>Main content</main></body></html>'
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
        '<html><body>Body Content<article>Article Content</article></body></html>'
      end

      it 'inserts line breaks between the elements' do
        expect(parsed_content).to eq "Body Content\nArticle Content"
      end
    end

    context 'when the main element is empty' do #https://www.pivotaltracker.com/story/show/154144112
      let(:raw_document) do
        "<html><body>Body Content<div id='main' role='main'></div></body></html>"
      end

      it 'extracts the body content' do
        expect(parsed_content).to eq 'Body Content'
      end
    end

    context 'when the html is empty' do
      let(:raw_document) { '<html></html>' }

      it { is_expected.to eq '' }
    end

    context 'when the html contains custom tags' do
      let(:raw_document) { '<custom-tag>content</custom-tag>' }

      it { is_expected.to eq 'content' }
    end

    context 'when the HTML includes a nav element' do
      let(:raw_document) do
        '<html><body><nav>Menu</nav>content</body></html>'
      end

      it 'omits the nav bar content' do
        expect(parsed_content).to eq 'content'
      end
    end

    context 'when the HTML includes a footer element' do
      let(:raw_document) do
        '<html><body>content<footer>footer</footer></body></html>'
      end

      it 'omits the footer content' do
        expect(parsed_content).to eq 'content'
      end
    end
  end

  describe '#redirect_url' do
    subject(:redirect_url) { html_document.redirect_url }

    it { is_expected.to eq nil }

    context 'when the HTML sets a redirection' do
      let(:raw_document) do
        '<html><meta http-equiv="refresh" content="0; URL=/new.html"></html>'
      end

      it 'returns the new url' do
        expect(redirect_url).to eq 'https://foo.gov/new.html'
      end

      context 'when the new URL is in double quotes' do
        let(:raw_document) do
          %(<html><meta http-equiv="refresh" content="0; URL='./new.html'"></html>)
        end

        it { is_expected.to eq 'https://foo.gov/new.html' }
      end

      context 'when the new URL is in single quotes' do
        let(:raw_document) do
          %(<html><meta http-equiv='refresh' content='0; URL="./new.html"'></html>)
        end

        it { is_expected.to eq 'https://foo.gov/new.html' }
      end

      context 'case-sensitivity' do
        let(:raw_document) do
          '<html><META http-equiv="REFRESH" content="0; URL=/new"></html>'
        end

        it 'is not case-sensitive' do
          expect(redirect_url).to eq 'https://foo.gov/new'
        end
      end

      context 'when the URL contains special characters' do
        let(:raw_document) do
          '<html><meta http-equiv="refresh" content="0; URL=https://www.foo.gov/my|url’s_weird?!"></html>'
        end

        it 'encodes the characters' do
          expect(redirect_url).to eq 'https://www.foo.gov/my%7Curl%E2%80%99s_weird?!'
        end
      end
    end
  end

  describe 'language' do
    subject(:language) { html_document.language }

    context 'when the code is not downcased' do
      let(:raw_document) { '<HTML lang="EN"></HTML>' }

      it { is_expected.to eq 'en' }
    end
  end
end
