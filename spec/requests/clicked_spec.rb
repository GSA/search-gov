require 'spec/spec_helper'

describe "Clicked" do
  before do
    @url = "http://localhost:3000/search?locale=en&m=false&query=electrocoagulation++%29++%28site%3Awww.uspto.gov+%7C+site%3Aeipweb.uspto.gov%29+"
    @unescaped_url = CGI::unescape(@url).gsub(' ','+')
    @query = "chicken & beef recall"
    @timestamp = "1271978905"
    @affiliate_name = "some affiliate"
    @position = "7"
    @module = "RECALL"
    @vertical = "web"
    @locale = "en"
  end

  context "when correct information is passed in" do

    it "should return success with a blank message body" do
      get '/clicked', :u=> @url, :q=> @query, :t=> @timestamp, :a=> @affiliate_name, :p=> @position, :s=> @module, :v=> @vertical, :l=> @locale
      response.success?.should be(true)
      response.body.should == ''
    end

    it "should log the click" do
      Click.should_receive(:log).with(@unescaped_url, @query, '2010-04-22 23:28:25', '127.0.0.1', @affiliate_name, @position, @module, @vertical, @locale, anything())
      get '/clicked', :u=> @url, :q=> @query, :t=> @timestamp, :a=> @affiliate_name, :p=> @position, :s=> @module, :v=> @vertical, :l=> @locale
    end

  end

  context "when click url is missing" do
    before do
      get '/clicked', :q=> @query, :t=> @timestamp, :a=> @affiliate_name, :p=> @position, :s=> @module, :v=> @vertical, :l=> @locale
    end

    it "should return success with a blank message body" do
      response.success?.should be(true)
      response.body.should == ''
    end

    it "should not log the click information" do
      Click.should_not_receive(:log)
    end
  end

end