# coding: utf-8
require 'spec_helper'

describe Misspelling do
  fixtures :misspellings, :affiliates

  describe "Creating new instance" do

    it { should validate_presence_of :wrong }
    it { should validate_presence_of :rite }
    it { should validate_uniqueness_of :wrong }
    it { should ensure_length_of(:wrong).is_at_least(3).is_at_most(80) }
    it { should_not allow_value("two words").for(:wrong) }
    %w(wwwgsa.gov español).each do |value|
      it { should allow_value(value).for(:wrong) }
    end

    it "should create a new instance given valid attributes" do
      Misspelling.create!(:wrong => "valueforwrong", :rite => "value for rite")
    end

    it "should strip whitespace from wrong/rite before inserting in DB" do
      wrong = " leadingandtraleingwhitespaces "
      rite = " leading and trailing whitespaces "
      misspelling = Misspelling.create!(:wrong => wrong, :rite => rite)
      misspelling.wrong.should == wrong.strip
      misspelling.rite.should == rite.strip
    end

    it "should downcase wrong/rite before entering into DB" do
      upcased = "CAPS"
      Misspelling.create!(:wrong => upcased, :rite => upcased)
      Misspelling.find_by_wrong("caps").rite.should == "caps"
    end

    it "should squish multiple whitespaces between words in rite before entering into DB" do
      wrong = "twospayces"
      rite = "two  spaces"
      misspelling = Misspelling.create!(:wrong=> wrong, :rite=>rite)
      misspelling.wrong.should == "twospayces"
      misspelling.rite.should == "two spaces"
    end

    it "should enqueue the spellchecking of SaytSuggestions via Resque" do
      ResqueSpec.reset!
      Resque.should_receive(:enqueue_with_priority).with(:high, SpellcheckSaytSuggestions, "valueforwrong", "value for rite")
      Misspelling.create!(:wrong => "valueforwrong", :rite => "value for rite")
    end

  end

  describe "#correct(phrase)" do
    it "should return the phrase with words spelling-corrected" do
      Misspelling.correct("barack ubama").should == "barack obama"
    end

    it "should return nil if phrase is nil" do
      Misspelling.correct(nil).should be_nil
    end
  end

end
