# coding: utf-8
require 'spec_helper'

describe String do
  describe "#fuzzily_matches?" do
    it "should return true" do
      "this.has-punctuation'and spaces ".fuzzily_matches?("thishaspunctuationandspaces").should be_true
    end
  end

  describe "#sentence_case" do
    it "should properly capitalize words in a sentence" do
      "Loren's visit to the CIA with O'Toole and al-Gaddafi wasn't fun, so I doubt he'll return.".sentence_case.should == "Loren's Visit to the CIA with O'Toole and al-Gaddafi Wasn't Fun, so I Doubt He'll Return."
      "Muammar al-Gaddafi".sentence_case.should == "Muammar al-Gaddafi"
    end
  end

  describe "#longest_common_substring(str)" do
    context "when there is overlap" do
      let(:s1) { "Add a group of terms all at once (i.e., click on “Bulk Upload”). To bulk upload: Create a new text file, one entry per line, for example, acadia national park okefenokee okefenokee swamp yosemite national park yosemite valley Save as a text file—{filename}.txt—on your computer. (Do not save as spreadsheet or word processing files, such as .xls or .doc.) Add, modify, or delete individual entries in the file. Browse for the text file on your computer. Upload the file to the Affiliate Center. Delete terms from the list. You may also delete individual terms that you don’t want listed, through “Current Entries”. Use “Filter” to search for particular terms to edit. Type-ahead on Other Web Pages You can also add the type-ahead search suggestions to your homepage—or wherever you have a search box on your website—by adding the type-ahead JavaScript code to the head to your HTML web page. Visit our Admin Center, select your site, and click on the Get Code option in the left-hand menu. For more details, read our post on How to Add Our Code to Your Website. Filed under type ahead how to" }
      let(:s2) { "About Us USASearch is a hosted site search service provided by the U.S. General Services Administration (GSA). USASearch is managed by GSA’s Office of Citizen Services and Innovative Technologies, the same office that provides HowTo.gov and USA.gov. You can use USASearch to power the search box on your federal, state, local, tribal, or territorial government website—at no cost. Why do you need search on your website? Usability studies show that more than half of all website visitors are search-dominant, about a fifth are link-dominant, and the rest exhibit mixed behavior. Whatever their preference, visitors expect to be able to find a search box on your website. Why should you use USASearch? We deliver fast and relevant results. We’re committed to openness in government and improving customer service. And, we’re free! Improve visitors’ search experience on your website. Sign up today. Contact Us USASearch Program Office of Citizen Services and Innovative Technologies U.S. General Services Administration Phone: 202-505-5315 E-mail: USASearch@gsa.gov @USASearch About Us | Terms of Service | Follow Us on Twitter | USASearch@gsa.gov An Official Website of the US Government Sponsored by GSA's Office of Citizen Services & Innovative Technologies" }
      it "should find the longest common substring between a string and a target string" do
        s1.longest_common_substring(s2).should == " a search box on your website"
        s2.longest_common_substring(s1).should == " a search box on your website"
      end
    end

    context "when there is no overlap" do
      let(:s1) { "Add a group of terms all at once (i.e., click on “Bulk Upload”). To bulk upload: Create a new text file, one entry per line, for example, acadia national park okefenokee okefenokee swamp yosemite national park yosemite valley Save as a text file—{filename}.txt—on your computer. (Do not save as spreadsheet or word processing files, such as .xls or .doc.) Add, modify, or delete individual entries in the file. Browse for the text file on your computer. Upload the file to the Affiliate Center. Delete terms from the list. You may also delete individual terms that you don’t want listed, through “Current Entries”. Use “Filter” to search for particular terms to edit. Type-ahead on Other Web Pages You can also add the type-ahead search suggestions to your homepage—or wherever you have a search box on your website—by adding the type-ahead JavaScript code to the head to your HTML web page. Visit our Admin Center, select your site, and click on the Get Code option in the left-hand menu. For more details, read our post on How to Add Our Code to Your Website. Filed under type ahead how to" }
      let(:s2) { "XQ" }
      it "should return an empty string" do
        s1.longest_common_substring(s2).should be_blank
      end
    end
  end
end
