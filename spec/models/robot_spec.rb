require 'spec_helper'

describe Robot do
  fixtures :robots
  before do
    @valid_attributes = {:domain => 'www.usa.gov', :prefixes => '/test/,/ignoreme/'}
  end

  context "when creating a new Robot" do
    it { should validate_presence_of :domain }
    it { should validate_uniqueness_of(:domain) }
  end

  let(:robot) { Robot.create!(@valid_attributes) }

  describe "#disallows?(target_path)" do
    context "when there are no prefixes for the domain" do
      let(:noprefix_robot) { Robot.create!(:domain => "www.usa.gov") }
      it "should return false" do
        noprefix_robot.disallows?('/test/doc.html').should be_false
      end
    end

    context "when there are prefixes for the domain" do
      context "when there is a match" do
        it "should return true" do
          robot.disallows?('/test/doc.html').should be_true
        end
      end

      context "when there is not a match" do
        it "should return false" do
          robot.disallows?('/ok/subdomain/test/doc.html').should be_false
        end
      end
    end
  end

  describe "#fetch_robots_txt" do
    context "when the file exists" do
      before do
        @html_io = open(Rails.root.to_s + '/spec/fixtures/txt/robots.txt')
        robot.stub!(:open).and_return @html_io
      end

      it "should return the robots.txt content" do
        robot.fetch_robots_txt.should == @html_io
      end
    end

    context "when some error occurs (timeout, etc)" do
      before do
        robot.stub!(:open).and_raise Exception.new("404 Document Not Found")
      end

      it "should log the problem and return nil" do
        Rails.logger.should_receive(:warn)
        robot.fetch_robots_txt.should be_nil
      end
    end
  end

  describe "#build_prefixes(robots_txt)" do
    context "when disallow prefixes are specified for *" do
      it "should assign a comma-separated list of prefixes, each with a trailing slash" do
        robot.build_prefixes(open(Rails.root.to_s + '/spec/fixtures/txt/robots.txt'))
        robot.prefixes.should == '/test/,/testitems/'
      end
    end

    context "when disallow prefixes are specified for usasearch agent" do
      it "should assign a comma-separated list of prefixes, each with a trailing slash" do
        robot.build_prefixes(open(Rails.root.to_s + '/spec/fixtures/txt/robots_usasearch.txt'))
        robot.prefixes.should == '/staging/'
      end
    end

    context "when no disallow prefixes are specified" do
      it "should leave the prefixes field blank" do
        robot.build_prefixes(open(Rails.root.to_s + '/spec/fixtures/txt/empty_robots.txt'))
        robot.prefixes.should be_blank
      end
    end
  end

  describe "#save_or_delete" do
    context "when robot model exists, but robots.txt has disappeared" do
      before do
        robot.stub!(:open).and_raise Exception.new("404 Document Not Found")
      end

      it "should delete the existing robot entry" do
        id = robot.id
        robot.save_or_delete
        Robot.find_by_id(id).should be_nil
      end
    end

    context "when robot model exists, and so does robots.txt" do
      before do
        robot.stub!(:open).and_return open(Rails.root.to_s + '/spec/fixtures/txt/robots.txt')
      end

      it "should update the prefixes field" do
        robot.save_or_delete
        robot.prefixes.should == '/test/,/testitems/'
      end
    end

    context "when no robot model exists yet" do
      let(:newrobot) { Robot.new(:domain => "www.dropme.gov") }

      context "when no robots.txt is available" do
        before do
          robot.stub!(:open).and_raise Exception.new("404 Document Not Found")
        end

        it "should not save the new record" do
          robot.save_or_delete
          Robot.find_by_domain("www.dropme.gov").should be_nil
        end
      end

      context "when the robots.txt is available" do
        before do
          robot.stub!(:open).and_return open(Rails.root.to_s + '/spec/fixtures/txt/robots.txt')
        end

        it "should save the new record with the prefixes field set" do
          robot.save_or_delete
          robot.prefixes.should == '/test/,/testitems/'
        end
      end
    end
  end

  describe "self#populate_from_indexed_domains" do
    fixtures :affiliates
    before do
      IndexedDomain.delete_all
      IndexedDomain.create!(:domain => 'foobar.gov', :affiliate_id => affiliates(:basic_affiliate).id)
      IndexedDomain.create!(:domain => 'foobar.gov', :affiliate_id => affiliates(:power_affiliate).id)
      IndexedDomain.create!(:domain => 'blat.gov', :affiliate_id => affiliates(:basic_affiliate).id)
      @foobar = Robot.create!(:domain => 'foobar.gov')
      @blat = Robot.new(:domain => 'blat.gov')
    end

    it "should process each domain once" do
      Robot.should_receive(:find_or_initialize_by_domain).with('foobar.gov').and_return @foobar
      Robot.should_receive(:find_or_initialize_by_domain).with('blat.gov').and_return @blat
      @foobar.should_receive(:save_or_delete)
      @blat.should_receive(:save_or_delete)
      Robot.populate_from_indexed_domains
    end
  end

  describe "self#update_for(domain)" do
    let(:some_domain) { "foo.gov" }

    it "should return the most up-to-date Robot possible for the domain" do
      Robot.should_receive(:find_or_initialize_by_domain).with(some_domain).and_return(robot)
      robot.should_receive(:save_or_delete)
      Robot.should_receive(:find_by_domain).with(some_domain).and_return(robot)
      Robot.update_for(some_domain).should == robot
    end
  end

  describe "#sitemap" do
    context "when the robots.txt file exists" do
      before do
        @html_io = open(Rails.root.to_s + '/spec/fixtures/txt/robots.txt')
        robot.stub!(:open).and_return @html_io
      end

      it "should return the first sitemap link found" do
        robot.sitemap.should == "http://www.example.gov/sitemap.xml"
      end
    end

    context "when the file does not exist" do
      before do
        robot.stub!(:open).and_raise Exception.new("404 Document Not Found")
      end

      it "should return nil" do
        robot.sitemap.should be_nil
      end
    end
  end
end
