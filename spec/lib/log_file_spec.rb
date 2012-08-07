require 'spec_helper'

describe Apache::LogFile do
	it "should create cache_file if options 'cached' is true" do
		lambda {
			Apache::LogFile.foreach( "spec/fixtures/log/test.log", :cached => true ) {}
		}.should change { File.exist?( "spec/fixtures/log/test.cache" ) }.from( false ).to( true )
	end

	it "should read cache_file if cache_file is newer" do
		processed = 0
		Apache::LogFile.foreach( "spec/fixtures/log/test2.log", :cached => true ) { |log|
			processed += 1
		}
		processed.should == 0
	end

	it "should not read cache_file if cached option is false" do
		processed = 0
		Apache::LogFile.foreach( "spec/fixtures/log/test2.log", :cached => false ) { |log|
			log.remote_ip.should == "64.0.0.1"
			processed += 1
		}
		processed.should == 2
	end

	after do
		File.delete "spec/fixtures/log/test.cache" rescue nil
		File.delete "spec/fixtures/log/test_tsv.cache" rescue nil
	end
end
