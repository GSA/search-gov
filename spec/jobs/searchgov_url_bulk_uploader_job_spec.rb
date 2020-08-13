# frozen_string_literal: true

describe SearchgovUrlBulkUploaderJob do
  it_behaves_like 'a searchgov job'

  describe '#perform' do
    let(:user) { users(:affiliate_admin) }

    let(:redis) { Redis.new(host: REDIS_HOST, port: REDIS_PORT) }
    let(:redis_key) { 'bulk_url_upload:some-file.txt:a-guid' }

    let(:urls) do
      [
        'https://agency.gov/one-url',
        'https://agency.gov/another-url'
      ]
    end
    let(:url_file_contents) { urls.join("\n") + "\n" }

    let(:perform) do
      saved_perform_delivery = ActionMailer::Base.perform_deliveries
      ActionMailer::Base.perform_deliveries = true

      subject.perform(user, redis_key)

      ActionMailer::Base.perform_deliveries = saved_perform_delivery
    end

    describe 'when there is a valid url list and a valid user' do
      before do
        SearchgovDomain.create(domain: 'agency.gov')
        redis.set(redis_key, url_file_contents)
      end

      it 'uploads the first url' do
        perform
        expect(SearchgovUrl.find_by(url: urls[0])).not_to be(nil)
      end

      it 'uploads the second url' do
        perform
        expect(SearchgovUrl.find_by(url: urls[1])).not_to be(nil)
      end

      it 'sends the notification email' do
        expect { perform }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'removes the url list from redis' do
        perform
        expect(redis.exists(redis_key)).to be(false)
      end
    end
  end
end
