# coding: utf-8
require 'spec_helper'

describe SaytSearch do
  fixtures :affiliates, :form_agencies
  let(:affiliate) { affiliates(:usagov_affiliate) }

  it "should return nothing with no suggestions and no affiliate" do
    search = SaytSearch.new(nil, 10)
    search.results.should be_empty
  end

  describe "with an affiliate" do
    let(:search) do
      search = SaytSearch.new('ohai', 10)
      search.affiliate = affiliate
      search
    end

    let(:form_agency) { form_agencies(:en_uscis) }

    let(:form1) do
      Form.create!(:form_agency_id => form_agency.id, :number => 'I-9') do |f|
        f.file_type = 'PDF'
        f.title = 'Employment Eligibility Verification'
        f.description = 'All U.S. employers must complete this form.'
        f.url = 'http://www.uscis.gov/files/form/i-9.pdf'
        f.abstract = 'some of the shortest government agency form'
      end
    end

    let(:form2) do
      Form.create!(:form_agency_id => form_agency.id, :number => 'I-129F') do |f|
        f.file_type = 'PDF'
        f.title = 'Petition for Alien Fiancé(e)'
        f.description = 'To petition to bring your fiancé(e) (K-1)'
        f.url = 'http://www.uscis.gov/files/form/i-129f.pdf'
      end
    end

    let(:form3) do
      Form.create!(:form_agency_id => form_agency.id, :number => 'I-539') do |f|
        f.file_type = 'PDF'
        f.title = 'Application To Extend/Change Nonimmigrant Status'
        f.description = "Please see the form's instructions for your specific nonimmigrant visa category."
        f.url = 'http://www.uscis.gov/files/form/i-539.pdf'
      end
    end

    let(:form4) do
      Form.create!(:form_agency_id => form_agency.id, :number => 'I-485') do |f|
        f.file_type = 'PDF'
        f.title = 'Application to Register Permanent Residence or Adjust Status FOO'
        f.description = 'To apply to adjust your status to that of a permanent resident of the United States.'
        f.url = 'http://www.uscis.gov/files/form/i-485.pdf'
      end
    end

    let(:form5) do
      Form.create!(:form_agency_id => form_agency.id, :number => 'I-485 Supplement E') do |f|
        f.file_type = 'Online'
        f.title = 'Instructions for I-485, Supplement E'
        f.description = 'To provide additional instructions for filing of adjustment of status (Form I-485).'
        f.url = 'http://www.uscis.gov/files/form/i-485supe.pdf'
        f.subfunction = "foo"
        f.public_code = "bar"
        f.line_of_business = "blat"
      end
    end

    let(:boosted_content1) do
      BoostedContent.create!(
        :affiliate => affiliate,
        :url => "http://www.someaffiliate.gov/foobar",
        :title => "The foo, bar, and baz page",
        :description => "All about foobar and baz, boosted to the top",
        :keywords => 'unrelated, terms',
        :auto_generated => false,
        :status => 'active',
        :publish_start_on => Date.yesterday
      )
    end

    let(:boosted_content2) do
      BoostedContent.create!(
        :affiliate => affiliate,
        :url => "http://www.someotheraffiliate.gov/foobar",
        :title => "Baz as in 'Baz Luhrmann'",
        :description => "He's made a bunch of bad movies",
        :keywords => 'luhrmann, gatsby',
        :auto_generated => false,
        :status => 'active',
        :publish_start_on => Date.yesterday
      )
    end

    it "should return JSON-ready SaytSuggestions" do
      3.times { |i| SaytSuggestion.create!(:phrase => "ohai-#{i.succ}", :affiliate => affiliate) }
      search.query = 'ohai'
      search.results.should == [
        {:label => 'ohai-1', :data => nil, :section => 'default'},
        {:label => 'ohai-2', :data => nil, :section => 'default'},
        {:label => 'ohai-3', :data => nil, :section => 'default'}
      ]
    end

    it "should return JSON-ready Forms" do
      5.times { |i| send "form#{i.succ}" } # Instantiate the forms, yo
      Form.reindex
      search.query = 'i-9'
      search.results.should == [
        {:label => 'Employment Eligibility Verification', :data => 'http://www.uscis.gov/files/form/i-9.pdf', :section => 'Forms'},
      ]
    end

    it "should return JSON-ready BoostedContents" do
      2.times { |i| send "boosted_content#{i.succ}" } # Instantiate the forms, yo
      BoostedContent.reindex
      search.query = 'baz'
      search.results.should =~ [
        {:label => "The foo, bar, and baz page", :data => 'http://www.someaffiliate.gov/foobar', :section => 'Recommendations'},
        {:label => "Baz as in 'Baz Luhrmann'", :data => 'http://www.someotheraffiliate.gov/foobar', :section => 'Recommendations'}
      ]
    end

    it "should reduce the number of SaytSuggestions by the number of alternate results" do
      15.times { |i| SaytSuggestion.create!(:phrase => "foo#{i.succ}", :affiliate => affiliate) }
      5.times { |i| send "form#{i.succ}" }
      2.times { |i| send "boosted_content#{i.succ}" }
      BoostedContent.reindex
      Form.reindex
      search.query = 'foo'
      search.results.select{|result| result[:section] == 'Forms'}.length.should == 1
      search.results.select{|result| result[:section] == 'Recommendations'}.length.should == 1
      search.results.select{|result| result[:section] == 'default'}.length.should == 8
    end

    it "should not reduce the number of SaytSuggestions if there are no alternate results" do
      11.times { |i| SaytSuggestion.create!(:phrase => "ohai#{i.succ}", :affiliate => affiliate) }
      5.times { |i| send "form#{i.succ}" }
      2.times { |i| send "boosted_content#{i.succ}" }
      BoostedContent.reindex
      Form.reindex
      search.query = 'ohai'
      search.results.length.should == 10
    end
  end
end
