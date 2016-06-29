shared_examples 'an analytics controller' do
  context 'when the user has analytics data' do
    let(:start_date) { '05/01/2014'.to_date }
    let(:end_date) { '05/26/2014'.to_date }

    it 'sets the analytics dates' do
      analytics = "#{site.name}_analytics"
      expect(session[analytics][:start]).to eq start_date
      expect(session[analytics][:end]).to eq end_date
    end
  end
end
