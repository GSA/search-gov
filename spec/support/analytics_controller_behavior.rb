shared_examples 'an analytics controller' do
  context 'when the user has analytics data' do
    let(:start_date) { '05/01/2014'.to_date }
    let(:end_date) { '05/26/2014'.to_date }

    it 'sets the analytics dates for the session' do
      analytics = "#{site.name}_analytics"
      expect(session[analytics][:start]).to eq start_date
      expect(session[analytics][:end]).to eq end_date
    end

    it { is_expected.to assign_to(:start_date).with(start_date) }
    it { is_expected.to assign_to(:end_date).with(end_date) }
  end
end
