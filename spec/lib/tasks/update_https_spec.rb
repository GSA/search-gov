require 'spec_helper'

describe "Update https rake task" do
  fixtures :affiliates, :rss_feed_urls
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/update_https')
    Rake::Task.define_task(:environment)
  end

  let(:bbt_attributes) do
    { url: 'http://travel.state.gov/content/travel/en.html',
      title: 'test',
      description: 'test',
      publish_start_on: Time.now,
      status: 'active' }
  end
  let(:affiliate) { affiliates(:basic_affiliate) }

  describe "usasearch:update_https" do
    let(:task) { 'usasearch:update_https' }
    subject(:invoke_task) { @rake[task].invoke('BoostedContent','url','srsly') }

    before do
      @rake[task].reenable
      quiet_puts #Comment out this line if you need to see debugging output
    end

    it "should have 'environment' as a prereq" do
      expect(@rake[task].prerequisites).to include("environment")
    end

    context 'when there are urls to update' do
      let!(:record) { affiliate.boosted_contents.create(bbt_attributes) }

      it 'updates the url' do
        invoke_task
        expect(record.reload.url).to eq 'https://travel.state.gov/content/travel/en.html'
      end

      context 'when the record is a Flickr profile' do
        let!(:profile) do
          affiliate.flickr_profiles.create(profile_type: 'user', url: 'www.flickr.com/photos/usdol', profile_id: 'abc123')
        end
        let(:invoke_task) { @rake[task].invoke('FlickrProfile','url','srsly') }

        it 'updates the url' do
          expect{invoke_task}.to change{profile.reload.url}.
            from('www.flickr.com/photos/usdol').
            to('https://www.flickr.com/photos/usdol')
        end

        it "ensures the url is readonly" do
          invoke_task
          expect(FlickrProfile.readonly_attributes).to match_array(%w{profile_type profile_id url})
        end
      end

      context 'when the record is a news item' do
        before do
          rss_feed_content = File.read(Rails.root.to_s + '/spec/fixtures/rss/wh_blog.xml')
          allow(HttpConnection).to receive(:get).with('http://www.whitehouse.gov/feed/blog/white-house').and_return(rss_feed_content)
        end

        let(:rss_feed_url) { rss_feed_urls(:white_house_blog_url) }
        let!(:news_item1) do
          rss_feed_url.news_items.create!(title: 'test', description: 'test',
                                          link: 'http://www.example.com',
                                          published_at: Time.now,
                                          guid: 'abc123')
        end


        subject(:invoke_task) { @rake[task].invoke('NewsItem','link','srsly') }

        it 'updates the link' do
          expect{ invoke_task }.to change{ news_item1.reload.link }.
            from('http://www.example.com').to('https://www.example.com')
        end

        context 'when there is a duplicate record' do
          before do
            item = rss_feed_url.news_items.new(title: 'test', description: 'test',
                                               link: 'https://www.example.com',
                                               published_at: Time.now,
                                               guid: 'abc456')
            item.save(validate: false)
          end

          it 'does not update the record' do
            expect{ invoke_task }.not_to change{ news_item1.reload.url }
          end
        end
      end

      context 'when the srsly flag is not included' do
        before { @rake[task].invoke('BoostedContent','url') }

        it 'does not update any records' do
          expect(record.reload.url).to eq 'http://travel.state.gov/content/travel/en.html'
        end
      end

      context 'when the host is already verified secure' do
        before { stub_const('Faraday', 'faraday') }

        it 'does not make a new request' do
          expect(Faraday).to_not receive(:head).with(anything)
          invoke_task
        end
      end

      context 'when the url lacks any protocol' do
        let!(:record) do
          affiliate.boosted_contents.new(bbt_attributes.merge(url: 'www.flickr.com')).save(validate: false)
          affiliate.boosted_contents.find_by_url('www.flickr.com')
        end

        it 'updates the url' do
          expect{ invoke_task }.to change{record.reload.url}.
            from('www.flickr.com').to('https://www.flickr.com')
        end
      end

      context 'when the host has not been verified secure' do
        let(:file) { double(File) }
        let!(:record) do
          affiliate.boosted_contents.delete_all
          affiliate.boosted_contents.create(bbt_attributes.merge(url: 'http://www.secure.com'))
        end

        before do
          stub_request(:head, 'https://www.secure.com').to_return( status: 200, body: '' )
          allow(File).to receive(:open).with('lib/tasks/secure_hosts.csv', 'a+').and_return(file)
          allow(file).to receive(:readlines).and_return([])
          allow(file).to receive(:close)
        end

        it 'writes the host to the secure hosts file' do
          expect(file).to receive(:puts).with('www.secure.com')
          invoke_task
        end
      end

      context 'when Faraday bombs' do
        let!(:record) do
          affiliate.boosted_contents.create(bbt_attributes.merge(url: 'http://www.foo.com'))
        end

        it 'does not update the record' do
          invoke_task
          expect(record.reload.url).to eq('http://www.foo.com')
        end
      end

      context 'when the url is invalid' do
        let!(:record) do
          affiliate.boosted_contents.new(bbt_attributes.merge(url: 'http://invalid url')).save(validate: false)
          affiliate.boosted_contents.find_by_url('http://invalid url')
        end

        it 'does not update the record' do
          invoke_task
          expect(record.reload.url).to eq('http://invalid url')
        end
      end

      #ensure we're updating the records that are currently breaking validation rules
      context 'when the record is invalid' do
        let!(:record) do
          affiliate.boosted_contents.new(bbt_attributes.merge(description: '')).save(validate: false)
          affiliate.boosted_contents.last
        end
      end
    end

    context 'when the url is an empty string' do
      before { affiliate.update_attribute(:favicon_url, '') }
      subject(:invoke_task) { @rake[task].invoke('Affiliate','favicon_url') }

      it 'does not check for https' do
        expect(Addressable::URI).to_not receive(:heuristic_parse).with('')
        invoke_task
      end
    end
  end
end
