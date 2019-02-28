require 'spec_helper'

describe ClickCounterJob do
  subject(:perform) { ClickCounterJob.perform_now(args) }

  let(:counter) { instance_double(ClickCounter) }
  let(:args) do
    { domain: 'www.agency.gov' }
  end

  it_behaves_like 'a searchgov job'

  it "updates the click counts for each domain's URLs" do
    allow(ClickCounter).to receive(:new).with(domain: 'www.agency.gov').
      and_return(counter)
    expect(counter).to receive(:update_click_counts)
    perform
  end
end
