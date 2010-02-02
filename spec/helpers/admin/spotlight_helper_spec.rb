require "#{File.dirname(__FILE__)}/../../spec_helper"
require 'ostruct'

describe Admin::SpotlightHelper do
  describe "#html_form_column" do
    it "should render a WYSIWYG text editor" do
      helper.should_receive(:fckeditor_textarea).once
      helper.html_form_column("some record", "some input name")
    end
  end

  describe "#html_column" do
    it "should sanitize HTML" do
      record = OpenStruct.new(:html=>"whatever")
      helper.should_receive(:sanitize).once.with(record.html)
      helper.html_column(record)
    end
  end
end