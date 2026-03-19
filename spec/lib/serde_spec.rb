# frozen_string_literal: true

require 'spec_helper'

describe Serde do
  describe '.serialize_hash' do
    subject(:serialize_hash) do
      described_class.serialize_hash(original_hash, 'en')
    end

    let(:original_hash) do
      ActiveSupport::HashWithIndifferentAccess.new(
        { 'title' => 'my title',
          'description' => 'my description',
          'content' => 'my content',
          'path' => 'http://www.foo.gov/bar.html',
          'promote' => false,
          'audience' => 'Everyone',
          'content_type' => 'EVENT',
          'tags' => 'this that',
          'searchgov_custom1' => 'this, Custom, CONTENT',
          'searchgov_custom2' => 'That custom, Content',
          'searchgov_custom3' => '123',
          'created' => '2018-01-01T12:00:00Z',
          'changed' => '2018-02-01T12:00:00Z',
          'created_at' => '2018-01-01T12:00:00Z',
          'updated_at' => '2018-02-01T12:00:00Z' }
      )
    end

    it 'stores the language fields with the language suffix' do
      expect(serialize_hash).to match(hash_including(
                                        { 'title_en' => 'my title',
                                          'description_en' => 'my description',
                                          'content_en' => 'my content' }
                                      ))
    end

    it 'removes the original language field keys' do
      expect(serialize_hash).not_to have_key('title')
      expect(serialize_hash).not_to have_key('description')
      expect(serialize_hash).not_to have_key('content')
    end

    it 'stores downcased audience' do
      expect(serialize_hash).to match(hash_including({ 'audience' => 'everyone' }))
    end

    it 'stores downcased content_type' do
      expect(serialize_hash).to match(hash_including({ 'content_type' => 'event' }))
    end

    it 'stores tags as a downcased array' do
      expect(serialize_hash).to match(hash_including({ 'tags' => ['this that'] }))
    end

    it 'stores searchgov_custom fields as downcased arrays' do
      expect(serialize_hash).to match(hash_including(
                                        { 'searchgov_custom1' => %w[this custom content],
                                          'searchgov_custom2' => ['that custom', 'content'],
                                          'searchgov_custom3' => ['123'] }
                                      ))
    end

    it 'updates the updated_at value' do
      expect(serialize_hash[:updated_at]).to be > 1.second.ago
    end

    it 'extracts URI params from the path' do
      expect(serialize_hash).to match(hash_including(
                                        basename: 'bar',
                                        extension: 'html',
                                        url_path: '/bar.html',
                                        domain_name: 'www.foo.gov'
                                      ))
    end

    context 'when language fields contain HTML/CSS' do
      let(:html) do
        <<~HTML
          <div style="height: 100px; width: 100px;"></div>
          <p>hello & goodbye!</p>
        HTML
      end

      let(:original_hash) do
        ActiveSupport::HashWithIndifferentAccess.new(
          title: '<b><a href="http://foo.com/">foo</a></b><img src="bar.jpg">',
          description: html,
          content: "this <b>is</b> <a href='http://gov.gov/url.html'>html</a>"
        )
      end

      it 'sanitizes the language fields' do
        expect(serialize_hash).to match(hash_including(
                                          title_en: 'foo',
                                          description_en: 'hello & goodbye!',
                                          content_en: 'this is html'
                                        ))
      end
    end

    context 'with Spanish language' do
      subject(:serialize_hash) do
        described_class.serialize_hash(original_hash, 'es')
      end

      let(:original_hash) do
        ActiveSupport::HashWithIndifferentAccess.new(
          title: 'Título de la página',
          description: 'Descripción en español',
          content: 'Contenido principal'
        )
      end

      it 'stores fields with the es suffix' do
        expect(serialize_hash).to match(hash_including(
                                          'title_es' => 'Título de la página',
                                          'description_es' => 'Descripción en español',
                                          'content_es' => 'Contenido principal'
                                        ))
      end

      it 'does not create en-suffixed fields' do
        expect(serialize_hash).not_to have_key('title_en')
      end
    end

    context 'when language fields contain special characters' do
      let(:original_hash) do
        ActiveSupport::HashWithIndifferentAccess.new(
          title: 'Quotes "double" & \'single\' + ampersands',
          description: 'Unicode: café résumé naïve',
          content: 'Symbols: <em>©</em> ® ™ — –'
        )
      end

      it 'sanitizes HTML and preserves non-HTML special characters' do
        expect(serialize_hash).to match(hash_including(
                                          'title_en' => 'Quotes "double" & \'single\' + ampersands',
                                          'description_en' => 'Unicode: café résumé naïve',
                                          'content_en' => 'Symbols: © ® ™ — –'
                                        ))
      end
    end

    context 'when the tags are a comma-delimited list' do
      let(:original_hash) do
        { tags: 'this, that' }
      end

      it 'converts the tags to an array' do
        expect(serialize_hash).to match(hash_including(tags: %w[this that]))
      end
    end

    context 'when array fields are already arrays' do
      let(:original_hash) do
        { tags: %w[already an array],
          searchgov_custom1: %w[pre split] }
      end

      it 'leaves them unchanged' do
        expect(serialize_hash).to match(hash_including(
                                          tags: %w[already an array],
                                          searchgov_custom1: %w[pre split]
                                        ))
      end
    end

    context 'when optional fields are missing' do
      let(:original_hash) do
        ActiveSupport::HashWithIndifferentAccess.new(
          title: 'Just a title',
          path: 'http://www.example.gov/page.html'
        )
      end

      it 'does not add nil audience or content_type' do
        expect(serialize_hash).not_to have_key(:audience)
        expect(serialize_hash).not_to have_key(:content_type)
      end

      it 'does not add nil tags or custom fields' do
        expect(serialize_hash[:tags]).to be_nil
        expect(serialize_hash[:searchgov_custom1]).to be_nil
      end

      it 'still processes language fields and URI params' do
        expect(serialize_hash).to match(hash_including(
                                          'title_en' => 'Just a title',
                                          basename: 'page',
                                          extension: 'html'
                                        ))
      end
    end

    context 'when path is missing' do
      let(:original_hash) do
        { title: 'No path document' }
      end

      it 'does not add URI params' do
        expect(serialize_hash).not_to have_key(:basename)
        expect(serialize_hash).not_to have_key(:extension)
        expect(serialize_hash).not_to have_key(:url_path)
        expect(serialize_hash).not_to have_key(:domain_name)
      end
    end
  end

  describe '.deserialize_hash' do
    subject(:deserialize_hash) do
      described_class.deserialize_hash(original_hash, :en)
    end

    let(:original_hash) do
      ActiveSupport::HashWithIndifferentAccess.new(
        { 'created_at' => '2018-08-09T21:36:50.087Z',
          'updated_at' => '2018-08-09T21:36:50.087Z',
          'path' => 'http://www.foo.gov/bar.html',
          'language' => 'en',
          'created' => '2018-08-09T19:36:50.087Z',
          'updated' => '2018-08-09T14:36:50.087-07:00',
          'changed' => '2018-08-09T14:36:50.087-07:00',
          'promote' => true,
          'tags' => 'this that',
          'title_en' => 'my title',
          'description_en' => 'my description',
          'content_en' => 'my content',
          'basename' => 'bar',
          'extension' => 'html',
          'url_path' => '/bar.html',
          'domain_name' => 'www.foo.gov' }
      )
    end

    it 'removes the language suffix from the text fields' do
      expect(deserialize_hash).to include(
        'title' => 'my title',
        'description' => 'my description',
        'content' => 'my content'
      )
    end

    it 'removes derivative fields' do
      expect(deserialize_hash).not_to have_key('basename')
      expect(deserialize_hash).not_to have_key('extension')
      expect(deserialize_hash).not_to have_key('url_path')
      expect(deserialize_hash).not_to have_key('domain_name')
      expect(deserialize_hash).not_to have_key('bigrams')
    end

    it 'removes language-suffixed keys' do
      expect(deserialize_hash).not_to have_key('title_en')
      expect(deserialize_hash).not_to have_key('description_en')
      expect(deserialize_hash).not_to have_key('content_en')
    end

    it 'preserves non-language, non-derivative fields' do
      expect(deserialize_hash).to include(
        'path' => 'http://www.foo.gov/bar.html',
        'language' => 'en',
        'promote' => true,
        'tags' => 'this that'
      )
    end
  end

  describe '.uri_params_hash' do
    subject(:result) { described_class.uri_params_hash(path) }

    let(:path) { 'https://www.agency.gov/directory/page1.html' }

    it 'computes basename' do
      expect(result[:basename]).to eq('page1')
    end

    it 'computes filename extension' do
      expect(result[:extension]).to eq('html')
    end

    it 'computes url_path' do
      expect(result[:url_path]).to eq('/directory/page1.html')
    end

    it 'computes domain_name' do
      expect(result[:domain_name]).to eq('www.agency.gov')
    end

    context 'when the extension has uppercase characters' do
      let(:path) { 'https://www.agency.gov/directory/PAGE1.PDF' }

      it 'computes a downcased version of filename extension' do
        expect(result[:extension]).to eq('pdf')
      end
    end

    context 'when there is no filename extension' do
      let(:path) { 'https://www.agency.gov/directory/page1' }

      it 'computes an empty filename extension' do
        expect(result[:extension]).to eq('')
      end
    end

    context 'when the URL has query parameters' do
      let(:path) { 'https://www.agency.gov/search?q=test&page=2' }

      it 'extracts the path without query string' do
        expect(result[:url_path]).to eq('/search')
      end

      it 'extracts basename from the path portion' do
        expect(result[:basename]).to eq('search')
      end
    end

    context 'when the URL has a fragment' do
      let(:path) { 'https://www.agency.gov/page.html#section-2' }

      it 'extracts the path without fragment' do
        expect(result[:url_path]).to eq('/page.html')
      end
    end

    context 'when the URL is a root path' do
      let(:path) { 'https://www.agency.gov/' }

      it 'extracts the root path' do
        expect(result[:url_path]).to eq('/')
      end
    end
  end
end
