require "#{File.dirname(__FILE__)}/../spec_helper"
describe Bing do

  describe "#run" do
    before do
      @rbing = mock('rbing')
      RBing.stub(:new).and_return(@rbing)
    end

    context "when affiliate has domains specified" do
      it "should use domains in query to Bing" do
        affiliate = Affiliate.new(:domains => %w(foo.com bar.com).join("\n"))
        @rbing.should_receive(:web).with("government",{:site=>["foo.com","bar.com"]})
        Bing.new(:query => "government", :affiliate => affiliate, :page => 0).run rescue nil
      end
    end

    context "when affiliate has no domains specified" do
      it "should use just query string and mil&gov domain filters" do
        @rbing.should_receive(:web).with("government",{:site=>["gov","mil"]})
        Bing.new(:query => "government", :affiliate => Affiliate.new, :page => 0).run rescue nil
      end
    end

    context "when affiliate is nil" do
      it "should use just query string and mil&gov domain filters" do
        @rbing.should_receive(:web).with("government",{:site=>["gov","mil"]})
        Bing.new(:query => "government", :affiliate => nil, :page => 0).run rescue nil
      end
    end

    context "when page offset is specified" do
      it "should specify the offset in the query to Bing" do
        @rbing.should_receive(:web).with("government",{:offset => 30,:site=>["gov","mil"]})
        Bing.new(:query => "government", :affiliate => nil, :page => 3).run rescue nil
      end
    end
  end

end
