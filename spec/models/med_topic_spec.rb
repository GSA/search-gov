require 'spec_helper'

describe MedTopic do
  let(:valid_attributes) {
    { :medline_title => 'Supreme Paranoia',
      :medline_url => "#{MedTopic::MEDLINE_BASE_URL}spanish/huevos_rancheros.html",
      :locale => 'es',
      :medline_tid => 42 }.freeze
  }

  it { is_expected.to validate_presence_of :medline_title }
  it { is_expected.to validate_presence_of :locale }
  it { is_expected.to validate_presence_of :medline_tid }
  it do
    is_expected.to have_many(:med_related_topics).
      dependent(:destroy).inverse_of(:med_topic)
  end
  it { is_expected.to have_many(:med_sites).dependent(:destroy).inverse_of(:med_topic) }
  it { is_expected.to have_many(:synonyms).dependent(:destroy).inverse_of(:topic) }


  it 'should create a new instance given valid attributes' do
    MedTopic.create!(valid_attributes)
  end

  it 'should delete MedTopicSyns associated with a MedTopic on deleting that MedTopic' do
    t = MedTopic.new(valid_attributes)
    t.save!
    t.synonyms.create({ :medline_title => 'rushoes rancheros' })
    t.destroy
    expect(MedSynonym.find_by_medline_title('rushoes rancheros')).to be_nil
  end

  describe '.medline_xml_file_name' do
    it 'should know the right medline xml file name to fetch' do
      expect(MedTopic).to receive(:medline_publish_date).and_return Date.parse('2011-04-16')
      expect(MedTopic.medline_xml_file_name(nil)).to eq('mplus_topics_2011-04-16.xml')
    end

    it 'should create a filename based on the date' do
      date = Date.parse('2011-04-21')
      expect(MedTopic.medline_xml_file_name(date)).to eq('mplus_topics_2011-04-21.xml')
    end
  end

  describe '.medline_publish_date(date)' do
    context 'when the date is not Sunday or Monday' do
      let(:date) { Date.parse('2012-07-24') }

      it 'should return the same day' do
        expect(MedTopic.medline_publish_date(date)).to eq(date)
      end
    end

    context 'when the date is a Sunday' do
      let(:date) { Date.parse('2012-07-22') }

      it 'should return the previous Saturday' do
        expect(MedTopic.medline_publish_date(date)).to eq(Date.parse('2012-07-21'))
      end
    end

    context 'when the date is a Monday' do
      let(:date) { Date.parse('2012-07-23') }

      it 'should return the previous Saturday' do
        expect(MedTopic.medline_publish_date(date)).to eq(Date.parse('2012-07-21'))
      end
    end
  end

  describe '.medline_xml_file_path' do
    let(:xml_file_name) { 'mplus_topics_2012-07-21.xml' }
    let(:xml_file_path) { 'tmp/medline/mplus_topics_2012-07-21.xml' }

    it 'should create tmp/medline directory' do
      expect(FileUtils).to receive(:mkdir_p).with(%r[/tmp/medline$])
      path = MedTopic.medline_xml_file_path(xml_file_name)
      expect(path).to be_end_with(xml_file_path)
    end
  end

  describe '.process_medline_xml' do
    let(:xml_file_path) { Rails.root.to_s + '/spec/fixtures/xml/mplus_topics_2012-07-21.xml' }
    let(:en_med_topic) { MedTopic.where(:locale => :en).first }
    let(:es_med_topic) { MedTopic.where(:locale => :es).first }
    let(:en_sites) { en_med_topic.med_sites.collect { |s| { :title => s.title, :url => s.url } } }
    let(:en_clinical_trial_sites) do
      [{ :title => 'Abdominal Pain',
         :url => 'http://clinicaltrials.gov/search/open/condition=%22Abdominal+Pain%22' },
       { :title => 'Pain',
         :url => 'http://clinicaltrials.gov/search/open/condition=%22Pain%22' },
       { :title => 'Stomach Diseases',
         :url => 'http://clinicaltrials.gov/search/open/condition=%22Stomach+Diseases%22' }]
    end

    context 'when there is no existing topic' do
      before { MedTopic.destroy_all }

      it 'should create MedTopic' do
        MedTopic.process_medline_xml(xml_file_path)
        expect(MedTopic.count).to eq(2)

        expect(en_med_topic.medline_tid).to eq(3061)
        expect(en_med_topic.medline_title).to eq('Abdominal Pain')
        expect(en_med_topic.medline_url).to eq('https://www.nlm.nih.gov/medlineplus/abdominalpain.html')
        expect(en_med_topic.locale).to eq('en')
        expect(en_med_topic.summary_html).to match(/abdomen/)
        expect(en_med_topic.synonyms.count).to eq(1)
        expect(en_med_topic.synonyms.first.medline_title).to eq('Bellyache')
        expect(en_med_topic.med_related_topics.count).to eq(2)
        expect(en_med_topic.med_related_topics.collect(&:related_medline_tid).sort).to eq([351, 4486])
        expect(en_med_topic.med_related_topics.where(:title => 'Pain').first.url).to eq('https://www.nlm.nih.gov/medlineplus/pain.html')
        expect(en_med_topic.med_related_topics.where(:title => 'Pelvic Pain').first.url).to eq('https://www.nlm.nih.gov/medlineplus/pelvicpain.html')
        expect(en_sites).to eq(en_clinical_trial_sites)

        expect(es_med_topic.medline_tid).to eq(3062)
        expect(es_med_topic.medline_title).to eq('Dolor abdominal')
        expect(es_med_topic.medline_url).to eq('https://www.nlm.nih.gov/medlineplus/spanish/abdominalpain.html')
        expect(es_med_topic.locale).to eq('es')
        expect(es_med_topic.summary_html).to match(/abdomen/)
        expect(es_med_topic.synonyms.count).to eq(3)
        expect(es_med_topic.synonyms.collect(&:medline_title)).to include('Dolor de barriga', 'Dolor de estómago', 'Dolor de panza')
        expect(es_med_topic.med_related_topics.count).to eq(1)
        expect(es_med_topic.med_related_topics.collect(&:related_medline_tid)).to eq([2072])
        expect(es_med_topic.med_related_topics.where(:title => 'Dolor').first.url).to eq('https://www.nlm.nih.gov/medlineplus/spanish/pain.html')
      end
    end

    context 'when there is an existing topic with the same medline_tid' do
      before do
        MedTopic.destroy_all
        MedTopic.create! do |t|
          t.medline_tid = 3061
          t.medline_title = 'a title'
          t.medline_url = 'http://www.nlm.nih.gov'
          t.locale = :en
          t.summary_html = 'nemodba'
          t.med_related_topics.build(:related_medline_tid => 100,
                                     :title => 'related title',
                                     :url => 'https://www.nlm.nih.gov/medlineplus/pelvicpain.html')
          t.synonyms.build(:medline_title => 'just a title')
        end
      end

      it 'should update existing MedTopic' do
        existing_med_topic = MedTopic.first

        MedTopic.process_medline_xml(xml_file_path)
        expect(MedTopic.count).to eq(2)
        expect(en_med_topic.id).to eq(existing_med_topic.id)
        expect(en_med_topic.medline_tid).to eq(3061)
        expect(en_med_topic.medline_title).to eq('Abdominal Pain')
        expect(en_med_topic.medline_url).to eq('https://www.nlm.nih.gov/medlineplus/abdominalpain.html')
        expect(en_med_topic.locale).to eq('en')
        expect(en_med_topic.summary_html).to match(/abdomen/)
        expect(en_med_topic.summary_html).not_to match(/nemodba/)
        expect(en_med_topic.synonyms.count).to eq(1)
        expect(en_med_topic.synonyms.first.medline_title).to eq('Bellyache')
        expect(en_med_topic.med_related_topics.count).to eq(2)
        expect(en_med_topic.med_related_topics.collect(&:related_medline_tid).sort).to eq([351, 4486])
        expect(en_med_topic.med_related_topics.where(:title => 'Pain').first.url).to eq('https://www.nlm.nih.gov/medlineplus/pain.html')
        expect(en_med_topic.med_related_topics.where(:title => 'Pelvic Pain').first.url).to eq('https://www.nlm.nih.gov/medlineplus/pelvicpain.html')
      end
    end

    context 'when there is an existing topic with a different medline_tid' do
      before do
        MedTopic.destroy_all
        MedTopic.create! do |t|
          t.medline_tid = 888
          t.medline_title = 'a title'
          t.medline_url = 'http://www.nlm.nih.gov'
          t.locale = :en
          t.summary_html = 'nemodba'
          t.med_related_topics.build(:related_medline_tid => 100,
                                     :title => 'related title',
                                     :url => 'https://www.nlm.nih.gov/medlineplus/pelvicpain.html')
          t.synonyms.build(:medline_title => 'just a title')
        end
      end

      it 'should delete the existing MedTopic' do
        existing_med_topic = MedTopic.first

        MedTopic.process_medline_xml(xml_file_path)
        expect(MedTopic.count).to eq(2)
        expect(en_med_topic.id).not_to eq(existing_med_topic.id)
        expect(en_med_topic.medline_tid).to eq(3061)
        expect(en_med_topic.medline_title).to eq('Abdominal Pain')
        expect(en_med_topic.medline_url).to eq('https://www.nlm.nih.gov/medlineplus/abdominalpain.html')
        expect(en_med_topic.locale).to eq('en')
        expect(en_med_topic.summary_html).to match(/abdomen/)
        expect(en_med_topic.summary_html).not_to match(/nemodba/)
        expect(en_med_topic.synonyms.count).to eq(1)
        expect(en_med_topic.synonyms.first.medline_title).to eq('Bellyache')
        expect(en_med_topic.med_related_topics.count).to eq(2)
        expect(en_med_topic.med_related_topics.collect(&:related_medline_tid).sort).to eq([351, 4486])
        expect(en_med_topic.med_related_topics.where(:title => 'Pain').first.url).to eq('https://www.nlm.nih.gov/medlineplus/pain.html')
        expect(en_med_topic.med_related_topics.where(:title => 'Pelvic Pain').first.url).to eq('https://www.nlm.nih.gov/medlineplus/pelvicpain.html')
      end
    end

    context 'when there is an existing synonym with the same medline_title' do
      before do
        MedTopic.destroy_all
        MedTopic.create! do |t|
          t.medline_tid = 3061
          t.medline_title = 'a title'
          t.medline_url = 'http://www.nlm.nih.gov'
          t.locale = :en
          t.summary_html = 'nemodba'
          t.synonyms.build(:medline_title => 'Bellyache')
        end
      end

      it 'should keep the synonym' do
        existing_synonym = MedSynonym.first

        MedTopic.process_medline_xml(xml_file_path)
        expect(en_med_topic.synonyms.count).to eq(1)
        expect(en_med_topic.synonyms.first).to eq(existing_synonym)
        expect(en_med_topic.synonyms.first.medline_title).to eq('Bellyache')
      end
    end

    context 'when there is an existing related_topic the same related_medline_tid' do
       before do
        MedTopic.destroy_all
        MedTopic.create! do |t|
          t.medline_tid = 3061
          t.medline_title = 'a title'
          t.medline_url = 'http://www.nlm.nih.gov'
          t.locale = :en
          t.summary_html = 'nemodba'
          t.med_related_topics.build(:related_medline_tid => 351,
                                     :title => 'related title',
                                     :url => 'https://www.nlm.nih.gov/medlineplus/pelvicpain.html')
        end
      end

      it 'should keep the med related topic' do
        existing_related_topic_id = MedRelatedTopic.first.id

        MedTopic.process_medline_xml(xml_file_path)
        expect(en_med_topic.med_related_topics.collect(&:id)).to include(existing_related_topic_id)
        expect(en_med_topic.med_related_topics.collect(&:related_medline_tid).sort).to eq([351, 4486])
      end
    end
  end

  describe '.download_medline_xml' do
    context 'when file is not present in the tmp/medline directory' do
      let(:xml_content) { 'xml content' }
      let(:xml_file_name) { 'mplus_topics_2012-07-21.xml' }
      let(:xml_file_path) { 'tmp/medline/mplus_topics_2012-07-21.xml' }
      let(:staging_xml_file_path) { 'tmp/medline/mplus_topics_2012-07-21.xml-staging' }
      let(:medline_uri) { URI.parse("https://medlineplus.gov/xml/#{xml_file_name}") }
      let(:staging_file) { double('staging file') }
      let(:response) { double('http response') }

      before do
        expect(File).to receive(:exist?).with(/#{xml_file_path}$/).and_return(false)
        expect(File).to receive(:open).
            with(/#{staging_xml_file_path}$/, 'w+', :encoding => Encoding::BINARY).
            and_yield(staging_file)

        expect(Net::HTTP).to receive(:get_response).with(medline_uri).and_yield(response)
        expect(response).to receive(:read_body).and_yield(xml_content)

        expect(staging_file).to receive(:write).with(xml_content)

        expect(File).to receive(:rename).with(/.+#{staging_xml_file_path}$/, /.+#{xml_file_path}$/)
      end

      it 'should return file path to medline xml' do
        file_path = MedTopic.download_medline_xml(Date.parse('2012-07-21'))
        expect(file_path).to match(/.+#{xml_file_path}$/)
      end
    end

    context 'when file is present in the tmp/medline directory' do
      let(:xml_file_path) { 'tmp/medline/mplus_topics_2012-07-21.xml' }

      before do
        expect(File).to receive(:exist?).with(/#{xml_file_path}$/).and_return(true)
        expect(Net::HTTP).not_to receive(:get_response)
      end

      it 'should return file path to medline xml' do
        file_path = MedTopic.download_medline_xml(Date.parse('2012-07-21'))
        expect(file_path).to match(/.+#{xml_file_path}$/)
      end
    end
  end

  describe '.search_for' do
    before do
      MedTopic.create! do |t|
        t.medline_tid = 3061
        t.medline_title = 'txf'
        t.medline_url = 'https://www.nlm.nih.gov/medlineplus/abdominalpain.html'
        t.locale = :en
        t.summary_html = 'Your abdomen extends from below your chest to your groin.'
        t.synonyms.build(:medline_title => 'Bellyache')
        t.med_related_topics.build(:related_medline_tid => 351,
                                   :title => 'Pain',
                                   :url => 'https://www.nlm.nih.gov/medlineplus/pelvicpain.html')
      end

      MedTopic.create!(:medline_tid => 351,
                       :medline_title => 'Pain',
                       :locale => 'en',
                       :medline_url => 'https://www.nlm.nih.gov/medlineplus/pelvicpain.html')

      MedTopic.create! do |t|
        t.medline_tid = 3062
        t.medline_title = 'txf'
        t.medline_url = 'https://www.nlm.nih.gov/medlineplus/spanish/abdominalpain.html'
        t.locale = :es
        t.summary_html = 'El abdomen se extiende desde abajo del pecho hasta la ingle.'
        t.synonyms.build(:medline_title => 'Dolor de barriga')
        t.synonyms.build(:medline_title => 'Dolor de estómago')
        t.synonyms.build(:medline_title => 'Dolor de panza')
        t.med_related_topics.build(:related_medline_tid => 2072,
                                   :title => 'Dolor',
                                   :url => 'https://www.nlm.nih.gov/medlineplus/spanish/pain.html')
      end

      MedTopic.create!(:medline_tid => 2072,
                       :medline_title => 'Dolor',
                       :locale => 'es',
                       :medline_url => 'https://www.nlm.nih.gov/medlineplus/spanish/pain.html')
    end

    it 'should return nil when there is no match' do
      expect(MedTopic.search_for('nothing')).to be_nil
    end

    it 'should assume en locale' do
      expect(MedTopic.search_for('txf').medline_tid).to eq(3061)
    end

    context 'when searching for one of the synonym medline title' do
      it 'should return matching med topic' do
        expect(MedTopic.search_for('bellyache').medline_tid).to eq(3061)
      end
    end

    it 'should find right topic depending on locale' do
      %w(en es).each { |locale|
        found_topics = MedTopic.search_for('txf', locale)
        expect(found_topics.locale).to eq(locale)
      }
    end
  end

  describe '#truncated_summary' do
    subject(:truncated_summary) { med_topic.truncated_summary }
    let(:summary_html) { '<h3>Lorem ipsum dolor sit amet.</h3>' }
    let(:med_topic) { MedTopic.new(summary_html: summary_html) }

    it { is_expected.to eq 'Lorem ipsum dolor sit amet.' }

    context 'when the summary html contains sentences that are too long' do
      let(:summary_html) do
        "This sentence is just right. This sentence is too long #{'x' * 200}."
      end

      it 'omits the long sentences' do
        expect(truncated_summary).to eq 'This sentence is just right.'
      end
    end

    context 'when the summary html contains excess whitespace' do
      let(:summary_html) { " \t Extra \n &nbsp; spaces. " }

      it 'squishes the whitespace' do
        expect(truncated_summary).to eq 'Extra spaces.'
      end
    end

    context 'when the summary html is missing punctuation' do
      let(:summary_html) { 'Missing punctuation' }

      it 'adds a trailing period' do
        expect(truncated_summary).to eq 'Missing punctuation.'
      end
    end
  end
end
