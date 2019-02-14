require 'spec_helper'

describe ClickCounterJob do
  let!(:searchgov_domain) { searchgov_domains(:agency) }
  let(:counter) { instance_double(ClickCounter) }

  subject(:perform) { ClickCounterJob.perform_now }

  describe '#perform' do
    it "updates the click counts for each domain's URLs" do
      allow(ClickCounter).to receive(:new).with(domain: 'www.agency.gov').
        and_return(counter)
      expect(counter).to receive(:update_click_counts)
      perform
    end
  end
end
