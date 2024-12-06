describe BulkZombieUrlUploadResultsMailer do
  describe '#results_email' do
    let(:user) { users(:affiliate_admin) }
    let(:filename) { 'test_file.csv' }
    let(:results) do
      results = BulkZombieUrls::Results.new(filename)
      results.delete_ok
      results
    end
    let(:mail) { described_class.with(user:, results:).results_email }

    it 'has the correct subject' do
      expect(mail.subject).to eq("Bulk Zombie URL upload results for #{filename}")
    end

    it 'has the correct recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'has the correct from header' do
      expect(mail.from).to eq([DELIVER_FROM_EMAIL_ADDRESS])
    end

    it 'has the correct reply-to' do
      expect(mail.reply_to).to eq([SUPPORT_EMAIL_ADDRESS])
    end

    it 'has the correct total number of URLs' do
      expect(mail.body.encoded).to match(/There were #{results.total_count} URLs/)
    end
  end
end
