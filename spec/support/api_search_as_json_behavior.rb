require 'hashie/mash'

shared_examples 'an API search as_json' do
  let(:search_rash) { search_rash = Hashie::Rash.new(JSON.parse(search.to_json)) }

  context 'when tweets are present' do
    fixtures :twitter_profiles

    let(:current_time) { DateTime.current }

    before do
      search.affiliate.twitter_profiles.destroy_all
      twitter_profile = twitter_profiles(:usagov)
      affiliate.twitter_profiles << twitter_profile

      Tweet.delete_all
      tweet = Tweet.create!(
        published_at: current_time,
        tweet_id: 1234567,
        tweet_text: 'Good morning, API!',
        twitter_profile_id: twitter_profile.twitter_id)

      search.stub(:tweets) { mock(ElasticTweetResults, results: [tweet]) }
    end

    it 'includes recent_tweets' do
      tweet = search_rash.recent_tweets.first.deep_symbolize_keys
      expect(tweet).to eq(created_at: current_time.to_time.iso8601,
                          name: 'USA.gov',
                          profile_image_url: 'http://a0.twimg.com/profile_images/1155238675/usagov_normal.jpg',
                          screen_name: 'usagov',
                          text: 'Good morning, API!',
                          url: 'https://twitter.com/usagov/status/1234567')
    end
  end

  context 'when federal register documents are present' do
    fixtures :federal_register_agencies, :federal_register_documents

    before do
      docs = [
        federal_register_documents(:'2014-15238'),
        federal_register_documents(:'2013-10000')
      ]
      search.stub(:federal_register_documents) do
        mock(ElasticFederalRegisterDocumentResults, results: docs)
      end
    end

    it 'includes federal register documents' do
      docs = search_rash.federal_register_documents.collect(&:deep_symbolize_keys)
      expect(docs.first).to eq(id: 804670240,
                               document_number: '2014-15238',
                               document_type: 'Notice',
                               title: 'Takes of Marine Mammals Incidental to Specified Activities; Taking Marine Mammals Incidental to a 3D Seismic Survey in Prudhoe Bay, Beaufort Sea, Alaska',
                               url: 'https://www.federalregister.gov/articles/2014/06/30/2014-15238/takes-of-marine-mammals-incidental-to-specified-activities-taking-marine-mammals-incidental-to-a-3d',
                               agency_names: ['National Oceanic and Atmospheric Administration'],
                               page_length: 14,
                               start_page: 36730,
                               end_page: 36743,
                               publication_date: '2014-06-30',
                               comments_close_date: nil)

      expect(docs.last).to eq(id: 1006471742,
                              document_number: '2013-10000',
                              document_type: 'Proposed Rule',
                              title: 'Hedge Funds and Private Equity Funds',
                              url: 'https://www.federalregister.gov/articles/2013/01/31/2013-31511/prohibitions-and-restrictions-on-proprietary-trading-and-certain-interests-in-and-relationships-with',
                              agency_names: ['National Oceanic and Atmospheric Administration'],
                              page_length: 1,
                              start_page: 8888,
                              end_page: 8889,
                              publication_date: '2013-01-31',
                              comments_close_date: '2013-03-31')
    end
  end

  context 'when job openings are present' do
    before do
      job_openings = [
        Hashie::Mash.new(id: 'usajobs:390049600',
                         position_title: 'Archeological Technician',
                         organization_name: 'National Park Service',
                         rate_interval_code: 'PH',
                         minimum: 18,
                         maximum: 18,
                         start_date: '2014-12-23',
                         end_date: '2014-12-31',
                         locations: [
                           'Mesa Verde National Park, CO'
                         ],
                         url: 'https://www.usajobs.gov/GetJob/ViewDetails/390049600',
                         org_codes: "XX00"),
        Hashie::Mash.new(id: 'ng:tabc:1018446',
                         position_title: 'Clerk II-License and Permit Specialist Intern',
                         organization_name: 'Texas Alcoholic Beverage Commission',
                         rate_interval_code: 'PH',
                         minimum: 11,
                         maximum: nil,
                         start_date: '2014-12-03',
                         end_date: '2014-12-29',
                         locations: [
                           'Arlington, TX'
                         ],
                         url: 'http://agency.governmentjobs.com/tabc/default.cfm?action=viewjob&jobid=1018446',
                         org_codes: "XX00")
      ]

      search.stub(:jobs) { job_openings }
    end

    it 'includes job openings' do
      jobs = search_rash.job_openings.collect(&:deep_symbolize_keys)
      expect(jobs.first).to eq(position_title: 'Archeological Technician',
                               organization_name: 'National Park Service',
                               rate_interval_code: 'PH',
                               minimum: 18,
                               maximum: 18,
                               start_date: '2014-12-23',
                               end_date: '2014-12-31',
                               locations: [
                                 'Mesa Verde National Park, CO'
                               ],
                               url: 'https://www.usajobs.gov/GetJob/ViewDetails/390049600',
                               org_codes: "XX00")

      expect(jobs.last).to eq(position_title: 'Clerk II-License and Permit Specialist Intern',
                              organization_name: 'Texas Alcoholic Beverage Commission',
                              rate_interval_code: 'PH',
                              minimum: 11,
                              maximum: nil,
                              start_date: '2014-12-03',
                              end_date: '2014-12-29',
                              locations: [
                                'Arlington, TX'
                              ],
                              url: 'http://agency.governmentjobs.com/tabc/default.cfm?action=viewjob&jobid=1018446',
                              org_codes: "XX00")
    end
  end

  context 'when health topics are present' do
    fixtures :med_topics, :med_related_topics, :med_sites

    before { search.stub(:med_topic) { med_topics(:cancer) } }

    it 'includes health_topics' do
      health_topics = search_rash.health_topics.collect(&:deep_symbolize_keys)
      expect(health_topics.first).to eq(title: 'Cancer',
                                        url: 'https://www.nlm.nih.gov/medlineplus/cancer.html',
                                        snippet: "Cancer begins in your cells, which are the building blocks of your body. Normally, your body forms new cells as you need them, replacing old cells that die. Sometimes this process goes wrong.",
                                        related_topics: [{ 'title' => 'Cancer Alternative Therapies',
                                                           'url' => 'https://www.nlm.nih.gov/medlineplus/canceralternativetherapies.html' },
                                                         { 'title' => 'Cancer and Pregnancy',
                                                           'url' => 'https://www.nlm.nih.gov/medlineplus/cancerandpregnancy.html' }],
                                        related_sites: [{ 'title' => 'Carcinoma',
                                                          'url' => 'http://clinicaltrials.gov/search/open/condition=%22Carcinoma%22' },
                                                        { 'title' => 'Neoplasms',
                                                          'url' => 'http://clinicaltrials.gov/search/open/condition=%22Neoplasms%22' }])
    end
  end
end
