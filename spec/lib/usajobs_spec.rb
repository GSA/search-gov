require 'spec_helper'

describe Usajobs do
  describe '.search(options)' do
    context "when there is some problem" do
      before do
        YAML.stub!(:load_file).and_return({'host' => 'http://nonexistent.server.gov',
                                           'endpoint' => '/test/search',
                                           'adapter' => Faraday.default_adapter})
        Usajobs.establish_connection!
      end

      it "should log any errors that occur" do
        Rails.logger.should_receive(:error).with("Trouble fetching USAJobs information: getaddrinfo: nodename nor servname provided, or not known")
        Usajobs.search(:query => 'jobs')
      end
    end
  end
end