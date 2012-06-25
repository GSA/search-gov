require 'spec/spec_helper'

describe AffiliateObserver do
  let(:rss_feed_content) { File.open(Rails.root.to_s + '/spec/fixtures/rss/youtube.xml').read }
  before { Kernel.stub(:open).and_return(rss_feed_content) }

  describe "#after_create" do
    context "when affiliate has exactly one SiteDomain" do
      it "should attempt to crawl/fetch/index documents in the background (at low priority) from that domain and other domains covered by it" do
        Resque.should_receive(:enqueue_with_priority).with(:low, SiteDomainCrawler, an_instance_of(Fixnum))
        affiliate = Affiliate.new(:display_name => 'my site search')
        affiliate.site_domains.build(:domain => "justone.gov")
        affiliate.save!
      end
    end

   context "when affiliate has more than one SiteDomain" do
      it "should not attempt to crawl/fetch/index documents" do
        Resque.should_not_receive(:enqueue_with_priority)
        affiliate = Affiliate.new(:display_name => 'my portal search')
        affiliate.site_domains.build(:domain => "justone.gov")
        affiliate.site_domains.build(:domain => "wait-there-is-another.gov")
        affiliate.save!
      end
    end
  end
end
