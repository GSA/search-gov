# frozen_string_literal: true

module OpenSearchCucumberDocuments
  INDEX = ENV.fetch('OPENSEARCH_SEARCH_INDEX')

  module_function

  def ensure_index!
    OpenSearch::Indexer.create_index
  end

  def ensure_seeded!
    return if @seeded

    ensure_index!
    index_documents(seed_corpus)
    @seeded = true
  end

  def index_documents(hashes)
    return if hashes.blank?

    body = hashes.flat_map do |hash|
      hash = hash.stringify_keys
      language = hash['language'].presence || 'en'
      path = hash['url'].presence || hash['path']
      title = hash['title']
      description = hash['description'].presence || title
      content = hash['content'].presence || description
      serialized = Serde.serialize_hash(
        { path: path, title: title, description: description, content: content },
        language
      )
      serialized[:language] = language

      [{ index: { _index: INDEX, _id: Digest::SHA256.hexdigest(path) } }, serialized]
    end

    OPENSEARCH_CLIENT.bulk(body: body, refresh: true)
  end

  def seed_corpus
    docs = []
    docs.concat(repeated_docs(45, 'https://www.whitehouse.gov/white-house/%<n>s',
                              'White House result %<n>s', 'The White House government news'))
    docs.concat(repeated_docs(25, 'https://www.whitehouse.gov/america/%<n>s',
                              'America result %<n>s', 'America government page'))
    docs.concat(repeated_docs(10, 'https://www.whitehouse.gov/president/%<n>s',
                              'President briefing %<n>s', 'President of the United States'))
    docs.concat(repeated_docs(20, 'https://www.usa.gov/president/%<n>s',
                              'USA President page %<n>s', 'President information on usa.gov'))
    docs.concat(repeated_docs(25, 'https://www.usa.gov/gov/%<n>s',
                              'gov result %<n>s', 'gov information on usa.gov'))
    docs.concat(repeated_docs(15, 'https://www.usa.gov/news/%<n>s',
                              'USA news %<n>s', 'News from USA.gov'))
    docs.concat(repeated_docs(10, 'https://www.usa.gov/agency/%<n>s',
                              'Agency page %<n>s', 'Agency information'))
    docs.concat(repeated_docs(15, 'https://blog.usa.gov/news/%<n>s',
                              'USA blog news %<n>s', 'News from the blog'))
    docs.concat(repeated_docs(5, 'https://answers.usa.gov/faq/%<n>s',
                              'FAQ %<n>s', 'Frequently asked questions'))
    docs.concat(repeated_docs(5, 'https://www.data.gov/app/%<n>s',
                              'Data app %<n>s', 'Open data application'))
    docs.concat(repeated_docs(5, 'https://search.gov/blog/post-%<n>s',
                              'gov blog %<n>s', 'gov blog post on search.gov'))
    docs.concat(repeated_docs(5, 'https://www.sba.gov/blogs/sba-%<n>s',
                              'SBA blog %<n>s', 'sba small business'))
    docs.concat(repeated_docs(15, 'https://www.epa.gov/jobs/%<n>s',
                              'EPA jobs opening %<n>s', 'Federal jobs at EPA'))
    docs.concat(repeated_docs(15, 'https://www.cdc.gov/jobs/%<n>s',
                              'CDC jobs opening %<n>s', 'Federal jobs at CDC'))
    docs.concat(repeated_docs(5, 'https://www.epa.gov/news/carbon-emissions-%<n>s',
                              'Carbon emissions report %<n>s', 'carbon emissions news'))
    docs.concat(repeated_docs(15, 'https://www.usa.gov/espanol/gobierno/%<n>s',
                              'Gobierno de USA %<n>s', 'Información del gobierno', 'es'))
    docs.concat(repeated_docs(10, 'https://www.usa.gov/espanol/presidente/%<n>s',
                              'Presidente %<n>s', 'El presidente de los Estados Unidos', 'es'))
    docs.concat(repeated_docs(5, 'https://www.usa.gov/espanol/trabajo/%<n>s',
                              'Trabajo federal %<n>s', 'Ofertas de trabajo', 'es'))
    docs << doc('http://petitions.whitehouse.gov/petition-1.html',
                'First petition article',
                'This is an article death star r2d2 xyz3 petition')
    docs << doc('http://petitions.whitehouse.gov/petition-2.html',
                'Second petition article',
                'This is an article on death r2d2 xyz3 star petition')
    docs << doc('https://www.healthcare.gov/hippopotamus', 'Hippopotamus', 'hippopotamus article')
    docs << doc('https://www.noaa.gov/collection', 'Information Collection', 'Proposed information collection')
    docs << doc('https://www.noaa.gov/tuna', 'Tuna fisheries', 'Atlantic bluefin tuna')
    docs << doc('https://www.usa.gov/query', 'query', 'A page about the query term')
    docs
  end

  def repeated_docs(count, url_template, title_template, description, language = 'en')
    count.times.map do |index|
      n = index + 1
      doc(format(url_template, n: n), format(title_template, n: n), description, language)
    end
  end

  def doc(url, title, description, language = 'en')
    { 'url' => url, 'title' => title, 'description' => description, 'language' => language }
  end
end

Before do
  OpenSearchCucumberDocuments.ensure_seeded!
rescue StandardError => e
  Rails.logger.warn("[Cucumber] OpenSearch seed skipped: #{e.message}")
end
