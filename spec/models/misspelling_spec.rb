require "#{File.dirname(__FILE__)}/../spec_helper"

describe Misspelling do
  fixtures :misspellings

  describe "Creating new instance" do

    should_validate_presence_of :wrong, :rite
    should_validate_uniqueness_of :wrong

    it "should create a new instance given valid attributes" do
      Misspelling.create!(:wrong => "value for wrong", :rite => "value for rite")
    end

    it "should strip whitespace from wrong/rite before inserting in DB" do
      wrong = " leading and traleing whitespaces "
      rite = " leading and trailing whitespaces "
      misspelling = Misspelling.create!(:wrong=> wrong, :rite=>rite)
      misspelling.wrong.should == wrong.strip
      misspelling.rite.should == rite.strip
    end

    it "should downcase wrong/rite before entering into DB" do
      upcased = "CAPS"
      Misspelling.create!(:wrong=> upcased, :rite=>upcased)
      Misspelling.find_by_wrong("caps").rite.should == "caps"
    end

    it "should squish multiple whitespaces between words in wrong/rite before entering into DB" do
      wrong = "two  spayces"
      rite = "two  spaces"
      misspelling = Misspelling.create!(:wrong=> wrong, :rite=>rite)
      misspelling.wrong.should == "two spayces"
      misspelling.rite.should == "two spaces"
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

  context "after saving a Misspelling" do
    before do
      @phrase = "only one c is necccessary"
      SaytSuggestion.create!(:phrase => @phrase)
    end

    it "should apply the correction to existing SaytSuggestions" do
      wrong = "necccessary"
      rite = "necessary"
      Misspelling.create!(:wrong=> wrong, :rite=>rite)
      SaytSuggestion.find_by_phrase(@phrase).should be_nil
      SaytSuggestion.find_by_phrase("only one c is necessary").should_not be_nil
    end
  end

end
